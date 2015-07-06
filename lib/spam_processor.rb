class SpamProcessor
  
  def self.parse_domains_info(csv_file, data)
    hash_from_csv(csv_file).each do |line|
      domain_name = line[:domain_name]
      (line.keys - [:domain_name]).each do |key|
        data[domain_name]["extra_attr"][key] = line[key]
      end
    end
    data.except *data.select { |domain, val| val["extra_attr"][:username].blank? }.keys
  end
  
  def self.process(job)
    domains = job.data.map { |domain, params| DomainName.new domain, params["extra_attr"], params["whois"] }
    Whois.lookup_multiple domains.select { |d| d.whois.record.blank? }
    abort_if_whois_is_blank domains
    DNS::Resolver.dig_multiple domains, records: [:a, :mx, :ns]
    DNS::SpamBase.check_multiple domains
    internal_lists_bulk_check domains
    suspension_bulk_check domains
    job.update_attributes status: "Completed", data: DomainName.multiple_to_hash(domains), info: "Completed on #{DateTime.now.strftime('%d %b %Y at %H:%M')}"
  rescue Exception => e
    job.update_attributes status: "Failed", data: DomainName.multiple_to_hash(domains), info: e.message
  end
  
  private
  
  def self.hash_from_csv(csv)
    mapping = { domainname:          :domain_name,
                lasttransaction:     :last_transaction,
                expire_datetime:     :expiration_date,
                email:               :email_address, 
                user_createdatetime: :signup_date,
                lastlogin:           :last_login,
                orderid:             :order_id }
    SmarterCSV.process(csv, strip_chars_from_headers: /'/, key_mapping: mapping).map do |hash|
      hash[:full_name] = hash[:firstname] + " " + hash[:lastname]
      hash.except(:firstname, :lastname)
    end
  end
  
  def self.abort_if_whois_is_blank(domains)
    domains_with_no_whois = domains.select { |d| d.whois.record.blank? }
    count = domains_with_no_whois.count
    raise "Failed to get whois data for " + count.to_s + " domain".pluralize(count) + ": " + domains_with_no_whois.map(&:name).join(", ") if count > 0
  end
  
  def self.internal_lists_bulk_check(domains)
    domains.each do |domain|
      domain.extra_attr[:vip_domain] = VipDomain.find_by(domain: domain.name).present?
      domain.extra_attr[:has_vip_domains] = VipDomain.find_by(username: domain.extra_attr["username"]).present?
      domain.extra_attr[:spammer] = Spammer.find_by(username: domain.extra_attr["username"]).present?
      domain.extra_attr[:internal_account] = InternalAccount.find_by(username: domain.extra_attr["username"]).present?
    end
  end
  
  def self.suspension_bulk_check(domains)
    domains.each do |domain|
      status = domain.whois.properties[:status].map { |s| s.downcase.gsub(/[[:blank:]]/, '') }
      a_record = domain.extra_attr[:host_records][:a].last
      
      domain.extra_attr[:suspended_by_registry] = suspended_by_registry?(status)
      domain.extra_attr[:suspended_by_enom] = status.include?("clienthold")
      domain.extra_attr[:suspended_by_namecheap] = domain.whois.properties[:nameservers].include?("dummysecondary.pleasecontactsupport.com") ||
                                                   domain.extra_attr[:host_records][:ns].include?("dummysecondary.pleasecontactsupport.com")
      domain.extra_attr[:expired] = if IPAddress.valid?(a_record)
        domain.whois.properties[:nameservers].include?("dns1.name-services.com") &&
        IPAddress("64.74.223.1/24").network.include?(IPAddress(a_record)) ||
        IPAddress("8.5.1.1/24").network.include?(IPAddress(a_record))
      else
        false
      end
      domain.extra_attr[:suspended_for_whois] = domain.whois.properties[:nameservers].include?("dns1.name-services.com") && a_record == "98.124.253.216"
      domain.extra_attr[:inactive] = domain.extra_attr[:expired] || domain.extra_attr[:suspended_by_registry] || domain.extra_attr[:suspended_by_enom] ||
                                     domain.extra_attr[:suspended_by_namecheap] || domain.extra_attr[:suspended_for_whois]
      domain.extra_attr[:blacklisted] = domain.extra_attr[:dbl] || domain.extra_attr[:surbl]
    end
  end
  
  def self.suspended_by_registry?(status)
    return true if status.include? "hold"
    return true if status.include? "serverhold"
    return true if status.include?("serverrenewprohibited") && status.include?("serverdeleteprohibited") && status.include?("serverupdateprohibited")
    false
  end
  
end
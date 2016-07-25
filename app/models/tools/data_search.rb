class Tools::DataSearch

  TLD_REGEX    = /(?:\.[a-z]+)+/i
  IP_REGEX     = /\d+\.\d+\.\d+\.\d+/
  EMAIL_REGEX  = /[a-z0-9\.!#$%&'*+-\/=?_|{}~`^]+@(?:(?>[a-z0-9]+[a-z0-9\-]*[a-z0-9]+|[a-z0-9]*)\.)+[a-z]+/i
  TICKET_REGEX = /[a-z]{3}\-[0-9]{3}\-[0-9]{5}/i

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :query, :object_type, :items, :internal_items

  validates :query, presence: true
  validates :object_type, inclusion: { in: ['domain', 'host', 'tld', 'ip_v4', 'email', 'kayako_ticket'] }

  def initialize query, object_type = 'domain', internal = 'remove'
    @query, @object_type, @internal, @internal_items = query, object_type, internal, []
    @items = parse_items(@query) if valid?
    search_internal_domains!     if valid? && ['domain', 'host', 'email'].include?(@object_type)
  end

  private

  def search_internal_domains!
    domains = Tools::InternalDomain.all.map { |d| DomainName.new d.name }

    @items = @items.map do |item|
      if internal?(item, domains)
        update_internal_items(item)
        @internal == 'remove' ? nil : item.upcase
      else
        item
      end
    end.compact
  end

  def internal? item, domains
    send "internal_#{@object_type}?", item, domains
  end

  def internal_domain? item, domains
    item_domain = DomainName.new(item)

    domains.find do |domain|
      domain.tld == item_domain.tld && domain.sld == item_domain.sld
    end.present?
  end

  def internal_host? item, domains
    internal_domain? item, domains
  end

  def internal_email? item, domains
    internal_domain? item.split('@').last, domains
  end

  def update_internal_items item
    @internal_items << item
  end

  def parse_items query
    send "parse_#{@object_type}", query
  end

  def parse_domain query
    DomainName.parse_multiple(query, remove_subdomains: true).map(&:name)
  end

  def parse_host query
    DomainName.parse_multiple(query, remove_subdomains: false).map(&:name)
  end

  def parse_tld query
    query.scan(TLD_REGEX).select { |tld| PublicSuffix.valid? tld }.map { |tld| '.' + PublicSuffix.parse(tld).tld }.uniq
  end

  def parse_ip_v4 query
    query.scan(IP_REGEX).select { |ip| IPAddress.valid?(ip) }
  end

  def parse_email query
    query.scan(EMAIL_REGEX).map(&:downcase).uniq
  end

  def parse_kayako_ticket query
    query.scan(TICKET_REGEX).uniq
  end

end

class HostingAbuseForm
  
  class IpFeedback
    
    include Virtus.model
    
    extend  ActiveModel::Naming
    include ActiveModel::Model
    include ActiveModel::Validations
    
    attribute :reporting_party, String
    attribute :ip_reported,     String
    attribute :header,          String
    attribute :body,            String
    
    attr_accessor :service
    
    validates :reporting_party, :ip_reported, :header, presence: true
    
  end
  
end
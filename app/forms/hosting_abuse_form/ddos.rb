class HostingAbuseForm
  
  class Ddos
    
    include Virtus.model
  
    extend  ActiveModel::Naming
    include ActiveModel::Model
    include ActiveModel::Validations
    
    attribute :domain_port, String
    attribute :block_type,  String
    attribute :logs,        String
    
    attr_accessor :service
    
    validates :domain_port, :block_type, :logs, presence: true
    
  end
  
end
class Legal::HostingAbuse::Form::Resource
  
  include Virtus.model
  
  extend  ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Validations
  
  attr_accessor :shared_plan_id, :service_id
  
  attribute :type_id,               Integer
  attribute :details,               String
  attribute :abuse_type_ids,        Array[Integer]
  attribute :lve_report,            String
  attribute :mysql_queries,         String
  attribute :process_logs,          String
  attribute :upgrade_id,            Integer
  attribute :impact_id,             Integer
  attribute :activity_type_ids,     Array[Integer]
  attribute :measure_ids,           Array[Integer]
  attribute :other_measure,         String
  attribute :db_governor_logs,      String
  
  validates :type_id,               presence: true
  validates :type_id,               inclusion: { in: [2, 3], message: 'is not applicable for Business Expert package' }, if: :business_expert?
  validates :type_id,               inclusion: { in: [1],    message: 'is not applicable for Private Email' },           if: :private_email?
  
  validates :details,               presence: true, if: -> { disc_space? || private_email? }
  
  with_options if: :lve_mysql? do |f|
    f.validates :abuse_type_ids,    presence: { message: 'at least one must be checked' }
    f.validates :upgrade_id,        presence: true
    f.validates :impact_id,         presence: true
    f.validates :lve_report,        presence: true, if: :lve_report_required?
    f.validates :mysql_queries,     presence: true, if: :mysql_queries_required?
    f.validates :process_logs,      presence: true, if: :process_logs_required?
  end
  
  with_options if: :cron? do |f|
    f.validates :activity_type_ids, presence: { message: 'at least one must be checked' }
    f.validates :measure_ids,       presence: { message: 'at least one must be checked' }
    f.validates :other_measure,     presence: true, if: :other_measure_required?
  end
  
  def name
    'resource'
  end
  
  def disc_space?
    type_id == 1
  end
  
  def lve_mysql?
    type_id == 2
  end
  
  def cron?
    type_id == 3
  end
  
  def lve_report_required?
    intersection = abuse_type_ids & [1, 2, 3, 4]
    intersection.present?
  end
  
  def mysql_queries_required?
    abuse_type_ids.include? 5
  end
  
  def process_logs_required?
    abuse_type_ids.include? 6
  end
  
  def other_measure_required?
    measure_ids.include? 3
  end
  
  def business_expert?
    shared_plan_id == 3
  end
  
  def private_email?
    service_id == 5
  end
  
  def type_id
    private_email? ? 1 : super
  end
  
  def abuse_type_ids= ids
    super ids.present? ? ids.delete_if(&:blank?) : []
  end
  
  def measure_ids= ids
    super ids.present? ? ids.delete_if(&:blank?) : []
  end
  
  def activity_type_ids= ids
    super ids.present? ? ids.delete_if(&:blank?) : []
  end
  
  def persist hosting_abuse
    hosting_abuse.resource ||= Legal::HostingAbuse::Resource.new
    hosting_abuse.resource.assign_attributes resource_params
  end
  
  private
  
  def resource_params
    attr_names = Legal::HostingAbuse::Resource.attribute_names.map(&:to_sym) + [:abuse_type_ids, :activity_type_ids, :measure_ids]
    self.attributes.slice(*attr_names).delete_if { |key, val| val.nil? }
  end
end
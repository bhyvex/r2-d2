class Legal::HostingAbuse::Form::Spam
  
  include Virtus.model(nullify_blank: true)
  
  extend  ActiveModel::Naming
  include ActiveModel::Model
  include ActiveModel::Validations
  
  attr_accessor :service_id
  
  attribute :detection_method_id,             Integer
  attribute :other_detection_method,          String
  attribute :queue_type_id,                   Integer
  attribute :bounces_queue_present,           Boolean
  attribute :outgoing_emails_queue,           Integer
  attribute :recepients_per_email,            Integer
  attribute :bounced_emails_queue,            Integer
  attribute :header,                          String
  attribute :body,                            String
  attribute :bounce,                          String
  attribute :example_complaint,               String
  attribute :reporting_party_ids,             Array[Integer]
  attribute :experts_enabled,                 Boolean
  attribute :ip_is_blacklisted,               Boolean
  attribute :blacklisted_ip,                  String
  attribute :involved_mailboxes_count,        Integer
  attribute :mailbox_password_reset,          Boolean
  attribute :involved_mailboxes,              String
  attribute :mailbox_password_reset_reason,   String
  attribute :involved_mailboxes_count_other,  Integer
  attribute :reported_ip,                     String
  attribute :reported_ip_blacklisted,         Boolean
  
  validates :detection_method_id, presence: true
  validates :queue_type_id,       presence: true, if: :queue?
  
  with_options if: -> { queue? && !bounces_queue_only? } do |f|
    f.validates :outgoing_emails_queue,           presence: true, numericality: true
    f.validates :recepients_per_email,            presence: true, numericality: true
    f.validates :header,                          presence: true
    f.validates :body,                            presence: true
    f.validates :bounced_emails_queue,            presence: true, numericality: true, if: :bounces_queue_present
    f.validates :bounce,                          presence: true,                     if: :bounces_queue_present
  end
  
  validates :involved_mailboxes_count_other,  presence: true, numericality: true, if: -> { queue? && !bounces_queue_only? && !private_email? && !low_mailboxes_count? }
  validates :involved_mailboxes,              presence: true,                     if: -> { queue? && !bounces_queue_only? && !private_email? &&  low_mailboxes_count? &&  mailbox_password_reset }
  validates :mailbox_password_reset_reason,   presence: true,                     if: -> { queue? && !bounces_queue_only? && !private_email? &&  low_mailboxes_count? && !mailbox_password_reset }
  
  with_options if: -> { queue? && bounces_queue_only? } do |f|
    f.validates :bounced_emails_queue,            presence: true, numericality: true
    f.validates :bounce,                          presence: true
  end
  
  with_options if: :feedback_loop? do |f|
    f.validates :example_complaint,               presence: true
    f.validates :reporting_party_ids,             presence: { message: 'at least one must be checked' }
    f.validates :reported_ip,                     presence: true, ip_address: true
  end
  
  validates :other_detection_method,              presence: true,                   if: :other_detection_method?
    
  validates :blacklisted_ip,                      presence: true, ip_address: true, if: -> { ip_is_blacklisted? && (queue? || other_detection_method?) }
  
  def queue?
    detection_method_id == 1
  end
  
  def feedback_loop?
    detection_method_id == 2
  end
  
  def other_detection_method?
    detection_method_id == 3
  end
  
  def low_mailboxes_count?
    [1, 2, 3, 4].include? involved_mailboxes_count
  end
  
  def bounced_emails?
    queue_type_id == 2
  end
  
  def private_email?
    service_id == 5
  end
  
  def bounces_queue_only?
    queue_type_id == 6
  end
  
  def reporting_party_ids= ids
    super ids.delete_if(&:blank?)
  end
  
end
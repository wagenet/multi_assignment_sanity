module MultiAssignmentSanity

  def self.included(base)
    base.extend MultiAssignmentSanity::ActsMethods
  end

  module ActsMethods

    def sanitize_multi_assignment_errors(options = {})
      unless self.include?(MultiAssignmentSanity::InstanceMethods)
        include MultiAssignmentSanity::InstanceMethods

        cattr_accessor :multi_assignment_sanity_options
        self.multi_assignment_sanity_options = options
        self.multi_assignment_sanity_options[:message] ||= "has error: {error}"

        validate :multi_parameter_errors
      end
    end

  end

  module InstanceMethods

    def assign_multiparameter_attributes(pairs)
      super
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      @multi_parameter_errors = e.errors
    end

    def multi_parameter_errors
      return unless @multi_parameter_errors.is_a?(Array)
      @multi_parameter_errors.each do |error|
        message = self.class.multi_assignment_sanity_options[:message]
        message.gsub!('{attr}', error.attribute.titleize)
        message.gsub!('{error}', error.exception.message)
        self.errors.add(error.attribute, message)
      end
      @multi_parameter_errors = []
    end

  end

end
ActiveRecord::Base.send(:include, MultiAssignmentSanity)
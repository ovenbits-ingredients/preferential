module Preferential

  def self.included(base)
    base.extend(ClassMethods)

    if base.respond_to?(:serialize)
      base.serialize "#{base.name.downcase}_preferences".to_sym
    end

    if base.respond_to?(:after_find)
      base.after_find :load_preferences
    end

  end

  module ClassMethods
    def pref_accessible(*args)
      self.attr_accessible(*args)
      define_method(:preferences){args}
      args.each do |method|
        define_method(method){get_preference(method)}
        define_method("#{method}=".to_sym) do |value|
          set_preference(method,value)
        end
      end
    end
  end

  def load_preferences
    # clean up user_preference hash
    # • initialize to empty hash if blank?
    # • remove orphaned key/value pairs
    class_preferences = "self.#{self.class.name.downcase}_preferences"
    eval("#{class_preferences} = {}") if eval(class_preferences).blank?
    eval(class_preferences).keep_if{|k,v| preferences.include?(k)}
  end

  def get_preference(pref_name)
    class_preferences = eval("self.#{self.class.name.downcase}_preferences")
    class_preferences[pref_name]
  end

  def set_preference(pref_name, pref_value)
    class_preferences = eval("self.#{self.class.name.downcase}_preferences")
    class_preferences[pref_name] = pref_value
  end

end
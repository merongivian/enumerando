require "enumerando/version"

class Enumerando::MethodsNames
  ENUMERABLE_FILTERING = %w(select reject)
  ENUMERABLE_BOOLEAN = %w(all? none?)

  def initialize(collection)
    @collection = collection
  end

  def element
    if uniform_collection?
      procable_boolean_methods(@collection.first)
    else
      procable_boolean_methods(Object) - ['singleton_class?']
    end
  end

  private

  def uniform_collection?
    @collection.all? { |element| @collection.first.class == element.class }
  end

  def procable_boolean_methods(element)
    element.class.instance_methods.grep(/\?/).map(&:to_s).select do |boolean_attribute|
      element.method(boolean_attribute).arity == 0
    end
  end
end

class Enumerando::MethodParser
  def initialize(method_name)
    @method_name = method_name
    @enumerable, @boolean = method_name.split('_')
  end

  def enumerable_method
    @method_name.end_with?('?') ? append_question_mark(@enumerable) : @enumerable
  end

  def boolean_method
    @method_name.end_with?('?') ? @boolean : append_question_mark(@boolean)
  end

  private

  def append_question_mark(method_name)
    method_name + '?'
  end
end

class Array
  def method_missing(meth, *, &block)
    if valid_enumerando_method?(meth.to_s)
      method_parser = method_name_parser(meth.to_s)

      self.send(method_parser.enumerable_method) do |element|
        element.send(method_parser.boolean_method)
      end
    else
      super
    end
  end

  private

  def valid_enumerando_method?(method_name)
    method_parser = method_name_parser(method_name)

    valid_boolean_methods.include?(method_parser.boolean_method) &&
      valid_enumerable_methods.include?(method_parser.enumerable_method)
  end

  def valid_boolean_methods
    Enumerando::MethodsNames.new(self).element
  end

  def valid_enumerable_methods
    Enumerando::MethodsNames::ENUMERABLE_FILTERING +
      Enumerando::MethodsNames::ENUMERABLE_BOOLEAN
  end

  def method_name_parser(method_name)
    Enumerando::MethodParser.new(method_name)
  end
end

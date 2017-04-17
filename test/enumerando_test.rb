require 'test_helper'

describe Enumerando do
  describe 'testing generated enum methods' do
    it 'returns filtering results' do
      value(['one', 'two', '', 'three', '', 'four'].reject_empty)
        .must_equal %w(one two three four)
      value(['one', 'two', nil, 'three', nil, 'four'].reject_nil)
        .must_equal %w(one two three four)
    end

    it 'returns a boolean result' do
      value(['', '', '', ''].all_empty?)
        .must_equal true
      value([1, 2, 3, 5, 7].none_even?)
        .must_equal false
    end

    it 'evaluates custom objects' do
      class Country
        def initialize(name)
          @name = name
        end

        def poor?
          false
        end

        def wealthy?
          true
        end
      end

      countries = [Country.new('US'), Country.new('UK'), Country.new('BRZ')]

      value(countries.all_wealthy?)
        .must_equal true

      value(countries.none_poor?)
        .must_equal true
    end

    #it 'returns results when all elements have integer as common method' do
      #value([1, 2.5, 4, 1.4].select_integer)
        #.must_equal [1, 4]
    #end

    it 'raises an undefined method error if an invalid method is used' do
      ->{ ['one', 'two', 'three'].select_integer }.must_raise NoMethodError
    end
  end

  describe Enumerando::MethodsNames do
    let(:element_methods) { Enumerando::MethodsNames.new(collection).element.sort }

    describe 'when all elements are of the same class' do
      let(:collection) { Array(element) * 3 }

      describe 'and are ruby base classes' do
        let(:element) { 1 }

        describe '#element' do
          it 'returns procable boolean methods for the class' do
            value(element_methods).must_equal %w(integer? odd? even? real? zero? nonzero? finite? infinite? positive? negative? nil? tainted? frozen? untrusted?).sort
          end
        end
      end

      describe 'and are custom classes' do
        class Person
          def honest?
            true
          end

          def thief?
            false
          end
        end

        let(:element) { Person.new }

        describe '#element' do
          it 'returns boolean methods for the elements class' do
            value(element_methods).must_equal %w(nil? tainted? frozen? untrusted? honest? thief?).sort
          end
        end
      end
    end

    describe 'and all elements are from different classes' do
      let(:collection) { [1, 'word', 4] }

      describe '#element' do
        it 'returns common boolean methods for all the classes' do
          value(element_methods).must_equal %w(nil? tainted? frozen? untrusted?).sort
        end
      end
    end
  end

  describe Enumerando::MethodParser do
    let(:parser) { Enumerando::MethodParser.new(method_name) }

    describe '#enumerable_method' do
      describe 'for boolean enumerando methods' do
        let(:method_name) { 'all_empty?' }

        it 'returns the enumerable method with the question mark' do
          value(parser.enumerable_method).must_equal 'all?'
        end
      end

      describe 'for filtering enumerando methods' do
        let(:method_name) { 'reject_empty' }

        it 'just retuns the method name' do
          value(parser.enumerable_method).must_equal 'reject'
        end
      end
    end

    describe '#boolean_method' do
      describe 'for filtering enumerando methods' do
        let(:method_name) { 'reject_empty' }

        it 'returns the boolean method with a question mark' do
          value(parser.boolean_method).must_equal 'empty?'
        end
      end

      describe 'for boolean enumerando methods' do
        let(:method_name) { 'all_empty?' }

        it 'returns the boolean method with a question mark' do
          value(parser.boolean_method).must_equal 'empty?'
        end
      end
    end
  end
end

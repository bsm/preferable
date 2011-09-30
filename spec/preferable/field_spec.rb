require 'spec_helper'

describe Preferable::Field do

  def field(type, opts = {})
    described_class.new :any, type, opts
  end

  def integer(opts = {})
    field :integer, opts
  end

  subject do
    described_class.new "color", "string", :if => lambda {|v| v =~ /^[A-F0-9]{6}$/ }, :default => '444444'
  end

  it 'should have a name' do
    subject.name.should == "color"
  end

  it 'should have a type' do
    subject.type.should == :string
  end

  it 'should have a default' do
    subject.default.should == '444444'
  end

  it 'should have options' do
    subject.options.keys.should == [:if]
  end

  it 'should reject invalid types' do
    lambda { described_class.new :any, :invalid }.should raise_error(ArgumentError)
  end

  it 'should check if values are assignable' do
    even = lambda {|v| (v % 2).zero? }
    is_2 = lambda {|v| v == 2 }

    integer(:if => even).valid?(1).should be(false)
    integer(:if => even).valid?(2).should be(true)
    integer(:unless => even).valid?(1).should be(true)
    integer(:unless => even).valid?(2).should be(false)
    integer(:if => even, :unless => is_2).valid?(2).should be(false)
    integer(:if => even, :unless => is_2).valid?(3).should be(false)
    integer(:if => even, :unless => is_2).valid?(4).should be(true)
  end

  it 'should type-cast strings' do
    field(:string).type_cast(nil).should == nil
    field(:string).type_cast(1).should == '1'
  end

  it 'should type-cast ints' do
    field(:integer).type_cast(nil).should == nil
    field(:integer).type_cast('1').should == 1
    field(:integer).type_cast(2.5).should == 2
    field(:integer).type_cast("").should == 0
  end

  it 'should type-cast floats' do
    field(:float).type_cast(nil).should == nil
    field(:float).type_cast('1').should == 1.0
    field(:float).type_cast(2.5).should == 2.5
    field(:float).type_cast("").should == 0
  end

  it 'should type-cast booleans' do
    field(:boolean).type_cast(nil).should == nil
    field(:boolean).type_cast('1').should == true
    field(:boolean).type_cast(0).should == false
    field(:boolean).type_cast(true).should == true
  end

  it 'should type-cast dates' do
    field(:date).type_cast('2011-01-01').should == Date.civil(2011, 1, 1)
    field(:date).type_cast(Date.civil(2011, 11, 11)).should == Date.civil(2011, 11, 11)
    field(:date).type_cast(Time.at(1234567890)).should == Date.civil(2009, 2, 13)
  end

  it 'should type-cast datetimes' do
    field(:datetime).type_cast('2011-01-01 12:10').should == Time.zone.local(2011, 1, 1, 12, 10)
    field(:datetime).type_cast(Time.at(1234567890)).should == Time.at(1234567890)
    field(:datetime).type_cast(Time.at(1234567890)).zone.should == "UTC"
  end

  it 'should type-cast arrays' do
    field(:array).type_cast('1').should == ['1']
    field(:array, :cast => :integer).type_cast('1').should == [1]
    field(:array, :cast => :integer).type_cast(['1', 2, 'B']).should == [1, 2, 0]
  end

end

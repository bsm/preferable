require 'spec_helper'

describe Preferable::Schema do

  it { should be_a(Hash) }
  it { should respond_to(:string) }
  it { should respond_to(:integer) }
  it { should respond_to(:float) }
  it { should respond_to(:date) }
  it { should respond_to(:datetime) }
  it { should respond_to(:array) }
  it { should respond_to(:boolean) }

  it 'should build and store field' do
    field = subject.field 'color', :string
    field.should be_a(Preferable::Field)
    subject.should == { :color => field }
  end

  it 'should provide shorthand method' do
    subject.integer :client_id
    subject.keys.should == [:client_id]
    subject.values.first.should be_a(Preferable::Field)
  end

  it 'should allow to specify options with shorthand method' do
    subject.integer :client_id, :default => 1
    subject.values.first.default.should == 1
  end

  it 'should allow specifying multiple fields with shorthand method' do
    subject.integer :first, :second
    subject.keys.should =~ [:first, :second]
  end

  it 'should allow specifying multiple fields with options with shorthand method' do
    subject.integer :first, :second, :default => 0
    subject.keys.should =~ [:first, :second]
    subject.values.map(&:default).should == [0, 0]
  end

end

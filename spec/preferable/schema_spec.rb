require 'spec_helper'

describe Preferable::Schema do

  subject do
    described_class.new
  end

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

end

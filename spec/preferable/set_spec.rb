require 'spec_helper'

describe Preferable::Set do

  subject do
    Preferable::Set.new 'User'
  end

  def preferences
    subject.except('_')
  end

  it 'should reference the model' do
    subject.model.should == User
  end

  it 'shold be serializable' do
    subject.set :color => '222222', :newsletter => '1'
    dumped = YAML.dump(subject)
    loaded = YAML.load(dumped)
    loaded.should == subject
    loaded.model.should == User
  end

  describe "reading" do

    it 'should return assignments or defaults' do
      subject[:color].should == '444444'
      subject[:color] = '222222'
      subject[:color].should == '222222'
    end

    it 'should return nil for invalid keys' do
      subject[:invalid].should be_nil
    end

  end

  describe "writing" do

    it 'should ignore invalid keys' do
      subject[:invalid] = '1'
      preferences.should == {}
    end

    it 'should set values' do
      subject[:color] = '222222'
      preferences.should == { :color => '222222' }
    end

    it 'should type cast values' do
      subject[:color] = 222222
      preferences.should == { :color => '222222' }
    end

    it 'should unset key when defaults are assigned' do
      subject[:color] = '222222'
      preferences.should == { :color => '222222' }
      subject[:color] = '444444'
      preferences.should == {}
    end

    it 'should unset key when nil is assigned' do
      subject[:color] = '222222'
      preferences.should == { :color => '222222' }
      subject[:color] = nil
      preferences.should == {}
    end

    it 'should allow mass-update' do
      subject.set 'color' => 222222, :newsletter => '1'
      preferences.should == { :color => '222222', :newsletter => true }
      subject.set :color => nil, :newsletter => false
      preferences.should == {}
    end

  end
end

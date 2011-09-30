require 'spec_helper'

describe Preferable::Set do

  let :user do
    User.new
  end

  let :admin do
    Admin.new
  end

  subject do
    user.preferences
  end

  it 'should wrap values' do
    described_class.wrap(user, subject).should_not be(subject)
    described_class.wrap(user, subject).should == subject
    described_class.wrap(user, subject).owner.should be(user)

    described_class.wrap(admin, subject).should be_instance_of(described_class)
    described_class.wrap(admin, subject).owner.should be(admin)

    described_class.wrap(user, {}).should be_instance_of(described_class)
    described_class.wrap(user, {}).owner.should be(user)
  end

  it 'should reference the owner' do
    subject.owner.should == user
  end

  it 'should be convertable to a simple hash' do
    subject.to_hash.should be_instance_of(Hash)
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
      subject.should == {}
    end

    it 'should set values' do
      subject[:color] = '222222'
      subject.should == { "color" => '222222' }
    end

    it 'should notify record about changes' do
      subject[:color] = '222222'
      user.should be_changed
      user.changed_attributes.should == { "preferences"=>{} }
    end

    it 'should type cast values' do
      subject[:color] = 222222
      subject.should == { "color" => '222222' }
    end

    it 'should unset key when defaults are assigned' do
      subject[:color] = '222222'
      subject.should == { "color" => '222222' }
      subject[:color] = '444444'
      subject.should == {}
    end

    it 'should unset key when nil is assigned' do
      subject[:color] = '222222'
      subject.should == { "color" => '222222' }
      subject[:color] = nil
      subject.should == {}
    end

    it 'should allow mass-update' do
      subject.set 'color' => 222222, :newsletter => '1'
      subject.should == { "color" => '222222', "newsletter" => true }
      subject.set :color => nil, :newsletter => false
      subject.should == {}
    end

  end
end

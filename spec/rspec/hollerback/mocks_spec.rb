require 'spec_helper'

shared_examples_for 'a callback-enabled function' do
  context "where the callback" do
    context "is defined" do
      it do
        subject
        expect(return_value).to be callback_value
      end

      context "and takes an arbitrary number of arguments" do
        let(:callback_target) { double('callback_target') }
        let(:callback) { Proc.new { |a, b| callback_target.received(a, b) } }
        let(:callback_args) { [1, 2] }
        let(:callback_value) { callback_args }

        it do
          expect(callback_target).to receive(:received).with(*callback_args).and_return(callback_args)
          subject
          expect(return_value).to eq(callback_value)
        end
      end
      context "and takes a block" do
        subject { expect(target).to receive(method).and_callback(callback_name, *callback_args, &callback_block_arg) }

        let(:callback_target) { double('callback_target') }
        let(:callback) { Proc.new { |&block| callback_target.received(block) } }
        let(:callback_block_arg) { Proc.new { "Callback block arg" } }
        let(:callback_value) { callback_block_arg }

        it do
          expect(callback_target).to receive(:received).with(callback_block_arg).and_return(callback_block_arg)
          subject
          expect(return_value).to eq(callback_value)
        end
      end
    end
    context "is not defined" do
      let(:callbacks) { Proc.new { } }
      it do
        subject
        expect { return_value }.to raise_error(NoMethodError)
      end
    end
  end
end

describe RSpec::Hollerback::Mocks do
  let(:non_hollerback_class) do
    stub_const 'TestClass', Class.new
    TestClass
  end
  let(:hollerback_class) do
    stub_const 'TestClass', Class.new
    TestClass.send(:include, Hollerback)
    TestClass
  end

  describe "#and_callback" do
    subject { expect(target).to receive(method).and_callback(callback_name, *callback_args) }

    let(:target) { hollerback_class.new }
    let(:method) { :foo }
    let(:callback_name) { :success }
    let(:callback_args) { [] }
    let(:callback_value) { "Success!" }
    let(:return_value) { target.send(method, &callbacks) }
    let(:callback) { Proc.new { callback_value } }
    let(:callbacks) { Proc.new { |on| on.send(callback_name, &callback) } }

    context "for a class that" do
      context "doesn't implement Hollerback" do
        let(:target) { non_hollerback_class }
        it do
          expect { subject }.to raise_error(ArgumentError)
          return_value
        end
      end
      context "implements Hollerback" do
        let(:target) { hollerback_class }
        it_behaves_like 'a callback-enabled function'
      end
    end
    context "for an object that" do
      context "doesn't implement Hollerback" do
        let(:target) { non_hollerback_class.new }
        it do
          expect { subject }.to raise_error(ArgumentError)
          return_value
        end
      end
      context "implements Hollerback" do
        it_behaves_like 'a callback-enabled function'
      end
    end
    context "is chained multiple times" do
      context "with the same callback" do
        subject { expect(target).to receive(method).and_callback(callback_name).and_callback(callback_name) }

        let(:callback_target) { double('callback_target') }
        let(:callback) { Proc.new { callback_target.received } }

        it do
          expect(callback_target).to receive(:received).twice.and_return(callback_value)
          subject
          expect(return_value).to eq(callback_value)
        end
      end
      context "with different callbacks" do
        subject { expect(target).to receive(method).and_callback(callback_name).and_callback(callback_two_name) }

        let(:callback_target) { double('callback_target') }

        # Callback 1
        let(:callback) { Proc.new { callback_target.received(callback_value) } }

        # Callback 2
        let(:callback_two) { Proc.new { callback_target.received(callback_two_value) } }
        let(:callback_two_name) { :another_success }
        let(:callback_two_value) { "Another success!" }

        # Callbacks
        let(:callbacks) do
          Proc.new do |on|
            on.send(callback_name, &callback)
            on.send(callback_two_name, &callback_two)
          end
        end

        it do
          expect(callback_target).to receive(:received).with(callback_value).ordered.and_return(callback_value)
          expect(callback_target).to receive(:received).with(callback_two_value).ordered.and_return(callback_two_value)
          subject
          expect(return_value).to eq(callback_two_value)
        end
      end
    end
    context "is followed by an #and_return" do
      subject { expect(target).to receive(method).and_callback(callback_name).and_return(mocked_return_value) }
      let(:mocked_return_value) { "Mocked return value." }

      it do
        subject
        expect(return_value).to eq(mocked_return_value)
      end
    end
  end
end

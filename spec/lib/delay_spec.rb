require 'spec_helper'

describe 'delay option' do
	let(:listener) { double('listener', delay: delay_proxy, event: true) }
	let(:publisher) { publisher_class.new }

	let(:arg1) { 'japan' }
	let(:delay_proxy) { double('delay') }
	let(:delay_option) { {hoge: 'hogehoge'} }

	it 'receives delay' do 
		listener.should_receive(:delay)
		delay_proxy.should_receive(:event).with(arg1)

		publisher.add_listener listener, delay: true
		publisher.send(:publish, :event, arg1)
	end		

	context 'w/ a option to delay method' do
		it 'receives delay w/ options' do
			listener.should_receive(:delay).with(delay_option)
			delay_proxy.should_receive(:event).with(arg1)

			publisher.add_listener listener, delay: delay_option
			publisher.send(:publish, :event, arg1)
		end
	end
end

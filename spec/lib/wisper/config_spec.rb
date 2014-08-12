require 'spec_helper'

describe Wisper::Config do
  let(:config){ Wisper.config }

  it 'responses to methods' do
    [
      :broadcaster,
      :broadcaster=,
      :prefix,
      :prefix=
    ].each do |method|
      expect(config).to respond_to(method)
    end
  end
end

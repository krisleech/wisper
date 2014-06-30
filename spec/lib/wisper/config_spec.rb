require 'spec_helper'

describe Wisper::Config do
  let(:config){ Wisper.config }

  it 'responses to methods' do
    [
      :broadcaster,
      :broadcaster=,
      :prefix,
      :prefix=,
      :skip_all,
      :skip_all=,
      :skip_all?,
      :temporary_skip_all=,
      :temporary_skip_all?
    ].each do |method|
      expect(config).to respond_to(method)
    end
  end
end

require 'spec_helper'

describe Wisper do
  it 'raises when included' do
    expect { Object.class_eval { include Wisper } }.to raise_error(RuntimeError, /Backwards incompatible change/)
  end
end

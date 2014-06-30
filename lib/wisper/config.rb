module Wisper
  class Config
    attr_accessor :broadcaster, :prefix, :skip_all

    def skip_all?
      !!skip_all
    end

    def temporary_skip_all=(value)
      Thread.current['__wisper_temporary_skip_all_listeners'] = value
    end

    def temporary_skip_all?
      !!Thread.current['__wisper_temporary_skip_all_listeners']
    end
  end
end

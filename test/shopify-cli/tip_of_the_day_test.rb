# frozen_string_literal: true
require 'test_helper'
require 'shopify-cli/tip_of_the_day'

module ShopifyCli
  class TipOfTheDayTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      root = ShopifyCli::ROOT
      FakeFS::FileSystem.clone(root + '/test/fixtures/tips.json')
      FakeFS::FileSystem.clone(root + '/lib/tips.json')
      @tips_path = File.expand_path(ShopifyCli::ROOT + '/test/fixtures/tips.json')
    end

    def teardown
      ShopifyCli::Config.clear
      super
    end

    def test_displays_first_tip
      result = TipOfTheDay.call(@tips_path)
      assert_includes result, 'Creating a new store'
    end

    def test_displays_sequential_tip
      TipOfTheDay.call(@tips_path)
      result = TipOfTheDay.call(@tips_path)
      assert_includes result, 'Did you know this CLI is open source'
    end

    def test_displays_nothing_when_all_tips_have_been_seen
      3.times do
        TipOfTheDay.call(@tips_path)
      end

      assert_nil TipOfTheDay.call(@tips_path)
    end

    def test_no_tips_shown_if_disabled_in_config
      # run_cmd("config tipoftheday --disable")
      ShopifyCli::Config.set('tipoftheday', 'enabled', false)

      assert_nil TipOfTheDay.call(@tips_path)
    end
  end
end
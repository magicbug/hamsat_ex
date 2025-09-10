defmodule Hamsat.TimeConversionTest do
  use ExUnit.Case, async: true
  
  alias Hamsat.Util
  
  describe "time conversions" do
    test "erl_to_utc_datetime correctly converts erlang datetime to UTC" do
      # Test with a known Erlang datetime tuple
      erl_datetime = {{2024, 1, 15}, {12, 0, 0}}
      
      result = Util.erl_to_utc_datetime(erl_datetime)
      
      # Should convert to 2024-01-15T12:00:00Z UTC
      expected = ~U[2024-01-15 12:00:00Z]
      assert DateTime.compare(result, expected) == :eq
    end
    
    test "utc_datetime_to_erl correctly converts UTC datetime to erlang tuple" do
      utc_datetime = ~U[2024-01-15 12:00:00Z]
      
      result = Util.utc_datetime_to_erl(utc_datetime)
      
      # Should convert back to erlang datetime tuple
      expected = {{2024, 1, 15}, {12, 0, 0}}
      assert result == expected
    end
    
    test "round trip conversion preserves time" do
      original_erl = {{2024, 1, 15}, {12, 0, 0}}
      
      # Convert erl -> UTC -> erl
      result = original_erl
               |> Util.erl_to_utc_datetime()
               |> Util.utc_datetime_to_erl()
      
      assert result == original_erl
    end
  end
  
  describe "known offset issue simulation" do
    test "demonstrates potential 20-25 minute offset" do
      # This test will help us understand if the issue is in our conversion
      # Let's simulate what might happen with satellite pass times
      
      # Assume satellite library returns time that user reports as "20 minutes off"
      # If user sees pass at 14:20 but expects 14:00, the library time might be off
      erl_datetime_from_satellite = {{2024, 1, 15}, {14, 20, 0}}
      
      converted_utc = Util.erl_to_utc_datetime(erl_datetime_from_satellite)
      
      # If this is supposed to represent 14:00 UTC, then there's a 20-minute offset
      expected_utc = ~U[2024-01-15 14:00:00Z]
      diff_seconds = DateTime.diff(converted_utc, expected_utc, :second)
      
      # This should show us the offset in seconds (1200 = 20 minutes)
      assert diff_seconds == 1200
    end
  end
end
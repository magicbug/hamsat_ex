defmodule HamsatWeb.ViewHelpersTest do
  use ExUnit.Case, async: true
  
  alias HamsatWeb.ViewHelpers
  alias Hamsat.Alerts.Pass
  alias Hamsat.Context
  
  describe "duration calculation" do
    test "duration/2 correctly handles erlang datetime tuples" do
      # Test with erlang datetime tuples (as returned by satellite library)
      start_erl = {{2024, 1, 15}, {12, 0, 0}}
      end_erl = {{2024, 1, 15}, {12, 10, 0}}
      
      result = ViewHelpers.duration(start_erl, end_erl)
      
      # Should be 10 minutes = 600 seconds = "10:00"
      assert result == "10:00"
    end
    
    test "duration/2 correctly handles DateTime structs" do
      # Test with proper DateTime structs
      start_dt = ~U[2024-01-15 12:00:00Z]
      end_dt = ~U[2024-01-15 12:10:00Z]
      
      result = ViewHelpers.duration(start_dt, end_dt)
      
      # Should be 10 minutes = 600 seconds = "10:00"
      assert result == "10:00"
    end
    
    test "pass_duration/1 correctly calculates duration from pass with erlang tuples" do
      # Create a mock pass with erlang datetime tuples
      aos_erl = {{2024, 1, 15}, {12, 0, 0}}
      los_erl = {{2024, 1, 15}, {12, 10, 0}}
      
      pass = %Pass{
        info: %{
          aos: %{datetime: aos_erl},
          los: %{datetime: los_erl}
        }
      }
      
      result = ViewHelpers.pass_duration(pass)
      
      # Should be 10 minutes = "10:00"
      assert result == "10:00"
    end
    
    test "duration calculation with different time formats" do
      # Test various durations
      
      # 1 minute 30 seconds
      start1 = {{2024, 1, 15}, {12, 0, 0}}
      end1 = {{2024, 1, 15}, {12, 1, 30}}
      assert ViewHelpers.duration(start1, end1) == "1:30"
      
      # 1 hour 5 minutes
      start2 = {{2024, 1, 15}, {12, 0, 0}}
      end2 = {{2024, 1, 15}, {13, 5, 0}}
      assert ViewHelpers.duration(start2, end2) == "1:05:00"
    end
  end
  
  describe "time_span function" do
    test "time_span/3 correctly handles erlang datetime tuples" do
      # Create a mock context
      context = %Context{timezone: "Etc/UTC", time_format: "24h"}
      
      # Test with erlang datetime tuples
      start_erl = {{2024, 1, 15}, {12, 0, 0}}
      end_erl = {{2024, 1, 15}, {12, 10, 0}}
      
      result = ViewHelpers.time_span(context, start_erl, end_erl)
      
      # Should format as time span
      assert result =~ "12:00:00 – 12:10:00"
    end
  end
end
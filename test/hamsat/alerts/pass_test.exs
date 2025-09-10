defmodule Hamsat.Alerts.PassTest do
  use ExUnit.Case, async: true
  
  alias Hamsat.Alerts.Pass
  alias Hamsat.Util
  
  @moduledoc """
  Tests for the Pass module, specifically focusing on fixing the satellite pass
  time offset issue where raw Erlang datetime tuples were being used in Timex 
  functions without proper conversion to DateTime structs.
  """
  
  describe "time calculations with erlang datetime tuples" do
    test "progression/2 correctly handles erlang datetime tuples" do
      # Create a mock pass with erlang datetime tuples (as returned by satellite library)
      aos_erl = {{2024, 1, 15}, {12, 0, 0}}
      los_erl = {{2024, 1, 15}, {12, 10, 0}}
      
      pass = %Pass{
        info: %{
          aos: %{datetime: aos_erl},
          los: %{datetime: los_erl}
        }
      }
      
      # Test with different "now" times
      now_before = ~U[2024-01-15 11:30:00Z]
      now_during = ~U[2024-01-15 12:05:00Z]
      now_after = ~U[2024-01-15 12:30:00Z]
      
      # These should work correctly after the fix
      assert Pass.progression(pass, now_before) == :upcoming
      assert Pass.progression(pass, now_during) == :in_progress  
      assert Pass.progression(pass, now_after) == :passed
    end
    
    test "next_event/2 correctly calculates time until next event" do
      # Create a mock pass with erlang datetime tuples
      aos_erl = {{2024, 1, 15}, {12, 0, 0}}
      los_erl = {{2024, 1, 15}, {12, 10, 0}}
      
      pass = %Pass{
        info: %{
          aos: %{datetime: aos_erl},
          los: %{datetime: los_erl}
        }
      }
      
      # Test 30 minutes before AOS
      now_before = ~U[2024-01-15 11:30:00Z]
      assert {:aos, 1800} = Pass.next_event(pass, now_before)  # 30 minutes = 1800 seconds
      
      # Test during pass (5 minutes after AOS)
      now_during = ~U[2024-01-15 12:05:00Z]
      assert {:los, 300} = Pass.next_event(pass, now_during)   # 5 minutes = 300 seconds
      
      # Test after pass
      now_after = ~U[2024-01-15 12:30:00Z]
      assert :never = Pass.next_event(pass, now_after)
    end
    
    test "demonstrates the fix for time offset issue" do
      # This test demonstrates that the fix ensures consistent time handling
      
      erl_datetime = {{2024, 1, 15}, {12, 0, 0}}
      utc_datetime = ~U[2024-01-15 12:00:00Z]
      
      # Convert the tuple properly first (this is what our fix does)
      proper_datetime = Util.erl_to_utc_datetime(erl_datetime)
      
      # These should be equal (both representing same moment in time)
      assert DateTime.compare(utc_datetime, proper_datetime) == :eq
      
      # Time difference should be zero
      assert DateTime.diff(proper_datetime, utc_datetime, :second) == 0
      
      # This demonstrates that the fix ensures consistent time representation
    end
  end
end
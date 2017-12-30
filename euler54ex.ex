defmodule Euler54ex do
  def main do
    File.stream!("p054_poker.txt", [:utf8])
    |> Enum.map(&process/1)
    |> Stream.filter(&(&1===:left))
    |> Enum.count
    |> IO.inspect
  end

  def process(line) do
    line |> get_hands |> compare_hands
  end

  def benchmark do
    start = Time.utc_now()
    Enum.each(1..100,fn _ -> main() end)
    IO.inspect Time.diff(Time.utc_now(), start ,:millisecond) / 100
  end

  defp card_2_ordinal({rank,_}) do
    String.split("23456789TJQKA", "", trim: true)
    |> Enum.find_index(&(rank === &1))
  end

  defp card_compare({v1,c1},{v2,c2}) do
    if c1 === c2, do: v1 > v2, else: c1 > c2
  end

  defp count_cards(hand) do
    hand
    |> Enum.map(&card_2_ordinal/1)
    |> Enum.reduce(%{},fn (x, acc) -> Map.update(acc, x, 1, &(&1+1)) end)
    |> Map.to_list
    |> Enum.sort(&card_compare/2)
  end

  defp straight_or_flush?(counted, suits) do
    case {straight?(counted), flush?(suits)} do
      {false, false} -> 0
      {true, false} -> 4
      {false, true} -> 5
      {true, true} -> 8 
    end
  end

  defp hand_value(hand) do
    counted = count_cards hand
    case hand_matches(counted) do
      0 -> {straight_or_flush?(counted, hand), counted}
      x -> {x, counted}
    end
  end

  defp hand_matches(counted) do 
    Enum.map(counted, fn {_,x} -> x end)
    |> case do
      [1,1,1,1,1] -> 0
      [2,1,1,1] -> 1
      [2,2,1] -> 2
      [3,1,1] -> 3
      [3,2] -> 6
      [4,1] -> 7
    end
  end

  defp flush?([{_, match}|t]) do
    Enum.all?(t, fn {_,x} -> x === match end)
  end

  defp straight?([{x, _}|t]) do  
    Enum.reduce_while(t,x, fn 
      ({i,_}, acc) -> if i === acc - 1, do: {:cont, acc - 1}, else: {:halt, false}
    end) |> is_number
  end

  defp compare_vals(l_counts,r_counts) do
    Enum.zip(l_counts, r_counts) |> Enum.find_value(fn 
      {{l,_},{r,_}} when l > r -> :left 
      {{l,_},{r,_}} when l < r -> :right
      _ -> false 
    end)
  end

  defp compare_hands({left, right}) do
    {l_val, l_counts} = hand_value left
    {r_val, r_counts} = hand_value right
    cond do 
      l_val > r_val -> :left
      l_val < r_val -> :right
      l_val == r_val -> compare_vals(l_counts, r_counts)
    end
  end

  defp get_hands(hand_str) do
    hand_str
    |> String.split
    |> Enum.map(&(String.split_at &1, 1))
    |> Enum.split(5)
  end
end

Euler54ex.main()
module AdjacentCells
  def adjacent_cells(coordinates)
    x = coordinates[0]
    y = coordinates[1]
    [[x, y + 1], [x, y - 1], [x + 1, y], [x - 1, y]]
  end
end
class Chess
end

class Board
  LETTER_MAP = {'a' => 0,'b' => 1,'c' => 2,'d' => 3,
                'e' => 4,'f' => 5,'g' => 6,'h' => 7 }
  NUMBER_MAP = LETTER_MAP.invert

  attr_accessor :grid, :black_pieces

  def initialize
    @grid = Array.new(8) {Array.new(8)}
    @black_pieces = []
    @white_pieces = []
    set_pieces
  end

  def [](pos) # =>
    letter, number = pos[0] , pos[1].to_i
    grid[number - 8][LETTER_MAP[letter]]
  end

  def []=(pos, piece)
    letter, number = pos[0] , pos[1].to_i
    grid[number - 8][LETTER_MAP[letter]] = piece
  end

  # # def move(start_pos, end_pos)
# #     begin
# #       unless self[start_pos].valid_move?(start_pos, end_pos)
# #
# #     rescue IllegalMoveError
# #       puts "Enter a valid move: "
# #       retry
# #     end
# #
# #     self[start_pos], self[end_pos] = nil, self[start_pos]
# #   end
#
#   nil
# end


  def set_pieces#(row, team)

    self["a8"] = SlidingPiece.new(:Rook, 'a8', self.grid, :black)
    self["h8"] = SlidingPiece.new(:Rook, 'h8', self.grid, :black)
    self['c8'] = SlidingPiece.new(:Bishop, 'c8', self.grid, :black)
    self['f8'] = SlidingPiece.new(:Bishop, 'f8', self.grid, :black)
    self['d8'] = SlidingPiece.new(:Queen, 'd8', self.grid, :black)
    self['b8'] = SteppingPiece.new(:Knight, 'b8', self.grid, :black)
    self['g8'] = SteppingPiece.new(:Knight, 'g8', self.grid, :black)
    self['e8'] = SteppingPiece.new(:King, 'e8', self.grid, :black)


    self["a1"] = SlidingPiece.new(:Rook, 'a1', self.grid, :white)
    self["h1"] = SlidingPiece.new(:Rook, 'h1', self.grid, :white)
    self['c1'] = SlidingPiece.new(:Bishop, 'c1', self.grid, :white)
    self['f1'] = SlidingPiece.new(:Bishop, 'f1', self.grid, :white)
    self['d1'] = SlidingPiece.new(:Queen, 'd1', self.grid, :white)
    self['b1'] = SteppingPiece.new(:Knight, 'b1', self.grid, :white)
    self['g1'] = SteppingPiece.new(:Knight, 'g1', self.grid, :white)
    self['e1'] = SteppingPiece.new(:King, 'e1', self.grid, :white)

  end

  def pos(position)
    x, y = position[0], position[1]
    "#{NUMBER_MAP[y]}#{8 - x}"
  end

  def draw_board
    grid.each_index do |col_index|
      (0..7).each do |row_index|
        new_pos = pos([col_index,row_index])
        if self[new_pos].nil?
          print "|_"
        else
          print "|#{self[new_pos].draw}"
        end
      end
      print "|"
      puts
    end

  end

end

class Piece
  LETTER_MAP = {'a' => 0,'b' => 1,'c' => 2,'d' => 3,
                'e' => 4,'f' => 5,'g' => 6,'h' => 7 }
  NUMBER_MAP = LETTER_MAP.invert

  attr_reader :piece_name, :board, :color
  attr_accessor :pos

  def initialize(piece_name, pos, board, color)
    @piece_name = piece_name
    @pos = pos
    @board = board
    @color = color
  end

  def moves

  end

  def draw
    if self.color == :white
       case self.piece_name
      when :King
        "\u2654"
      when :Queen
        "\u2655"
      when :Rook
        "\u2656"
      when :Bishop
        "\u2657"
      when :Knight
        "\u2658"
      when :Pawn
        "\u2659"
      end

    elsif self.color == :black
      case self.piece_name
      when :King
        "\u265A"
      when :Queen
        "\u265B"
      when :Rook
        "\u265C"
      when :Bishop
        "\u265D"
      when :Knight
        "\u265E"
      when :Pawn
        "\u265F"
      end
    end


  end
end

class SlidingPiece < Piece
  #Bishop/Rook/Queen
  #Needs to check path to target recursively

  def initialize(piece_name, pos, board, color)
    super
    set_move_types
  end

  def set_move_types
    case piece_name
    when :Rook
      @move_horiz = true
      @move_diag = false
    when :Bishop
      @move_horiz = false
      @move_diag = true
    when :Queen
      @move_horiz = true
      @move_diag = true
    end
  end

  def move_horiz?
    @move_horiz
  end

  def move_diag?
    @move_diag
  end

  def same_team?(other_piece)
    self.color == other_piece.color
  end

  def moves
    moves = []
    origin = self.pos
    o_letter = origin[0]
    o_number = origin[1].to_i
    letter_number = LETTER_MAP[o_letter]

    # if @move_horiz == true
    #   ('a'..'h').each do |letter|
    #     moves << "#{letter}#{o_number}" unless "#{letter}#{o_number}" == origin
    #   end
    #   (1..8).each do |num|
    #     moves << "#{o_letter}#{num}" unless "#{o_letter}#{num}" == origin
    #   end
    # end

    if @move_horiz == true
      (1..8).each do |i|
        if (letter_number + i).between?(0, 7) && (o_number).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number + i]}#{o_number}",:E,i]
        end
        if (letter_number - i).between?(0, 7) && (o_number).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number - i]}#{o_number}",:W,i]
        end
        if (letter_number).between?(0, 7) && (o_number + i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number]}#{o_number + i}",:N,i]
        end
        if (letter_number).between?(0, 7) && (o_number - i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number]}#{o_number - i}",:S,i]
        end
      end
    end

    if @move_diag == true
      (1..8).each do |i|
        if (letter_number + i).between?(0, 7) && (o_number + i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number + i]}#{o_number + i}",:NE,i]
        end
        if (letter_number + i).between?(0, 7) && (o_number - i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number + i]}#{o_number - i}",:SE,i]
        end
        if (letter_number - i).between?(0, 7) && (o_number + i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number - i]}#{o_number + i}",:NW,i]
        end
        if (letter_number - i).between?(0, 7) && (o_number - i).between?(1, 8)
          moves << ["#{NUMBER_MAP[letter_number - i]}#{o_number - i}",:SW,i]
        end
      end
    end

    moves
  end
end

class SteppingPiece < Piece
  #Knight/King
  def initialize(piece_name, pos, board, color)
    super
  end
end

class IllegalMoveError < StandardError
end

# test_bishop = SlidingPiece.new(:Bishop, "a1", Board.new, :black)
# test_bishop.moves.each {|move| p move}

# test_rook = SlidingPiece.new(:Rook, "a8", Board.new, :black)
# test_rook.moves.each {|move| p move}

# test_queen = SlidingPiece.new(:Queen, "c4", Board.new, :black)
# test_queen.moves.each {|move| p move}


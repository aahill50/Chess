#TODO: make sure Piece subclass moves arrays get updated every turn

class Chess
  attr_reader :board

  def initialize(board  = Board.new)
    @turn = :white
    @board = board
  end

  def play
    self.board.draw_board

    while board #NEED STOP CONDITION

      puts "#{@turn.to_s.capitalize} choose a move: b8,a6 for example"
      player_move = gets.chomp.split(",")
      start_pos, end_pos = player_move[0], player_move[1]

      if valid_start?(start_pos, @turn) && valid_end?(start_pos, end_pos)
        self.board.move(start_pos, end_pos)
        self.board.draw_board
        switch_turn
      end
    end
  end

  def switch_turn
    @turn = (@turn == :white ? :black : :white)
  end

  def valid_start?(pos, color)
    if self.board[pos].nil?
      puts "There is no piece there!"
      return false
    end

    return true if self.board[pos].color == color

    puts "That's not your piece!"
  end

  def valid_end?(start_pos, end_pos)
    if self.board[start_pos].moves.include?(end_pos)
      return true
    else
      puts "That's not a valid move"
      return false
    end
  end

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

  def move(start_pos, end_pos)
    # begin
    #   unless self[start_pos].valid_move?(start_pos, end_pos)
    #
    # rescue IllegalMoveError
    #   puts "Enter a valid move: "
    #   retry
    # end

    self[start_pos], self[end_pos] = nil, self[start_pos]
  # end

    nil
  end



  def set_pieces#(row, team)

    self["a8"] = SlidingPiece.new(:Rook, 'a8', self, :black)
    self["h8"] = SlidingPiece.new(:Rook, 'h8', self, :black)
    self['c8'] = SlidingPiece.new(:Bishop, 'c8', self, :black)
    self['f8'] = SlidingPiece.new(:Bishop, 'f8', self, :black)
    self['d8'] = SlidingPiece.new(:Queen, 'd8', self, :black)
    self['b8'] = SteppingPiece.new(:Knight, 'b8', self, :black)
    self['g8'] = SteppingPiece.new(:Knight, 'g8', self, :black)
    self['e8'] = SteppingPiece.new(:King, 'e8', self, :black)


    self["a1"] = SlidingPiece.new(:Rook, 'a1', self, :white)
    self["h1"] = SlidingPiece.new(:Rook, 'h1', self, :white)
    self['c1'] = SlidingPiece.new(:Bishop, 'c1', self, :white)
    self['f1'] = SlidingPiece.new(:Bishop, 'f1', self, :white)
    self['d1'] = SlidingPiece.new(:Queen, 'd1', self, :white)
    self['b1'] = SteppingPiece.new(:Knight, 'b1', self, :white)
    self['g1'] = SteppingPiece.new(:Knight, 'g1', self, :white)
    self['e1'] = SteppingPiece.new(:King, 'e1', self, :white)

  end

  def pos(position)
    x, y = position[0], position[1]
    "#{NUMBER_MAP[y]}#{8 - x}"
  end

  def draw_board
    num = 9
    ('A'..'H').each {|letter| print "|#{letter}"}
      puts "|"
    grid.each_index do |col_index|
      num -= 1
      (0..7).each do |row_index|
        new_pos = pos([col_index,row_index])
        if self[new_pos].nil?
          print "|_"
        else
          print "|#{self[new_pos].draw}"
        end
      end
      print "|#{num}"
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

  def valid_moves

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

  def inspect
    {:position => pos,
      :class => self.class}
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
    move_choices = []
    origin = self.pos
    o_letter = origin[0]
    o_number = origin[1].to_i
    letter_number = LETTER_MAP[o_letter]

    if @move_horiz
      move_choices += [
        [ 1, 0],
        [-1, 0],
        [ 0,-1],
        [ 0, 1]
        ]
    end
    if @move_diag
      move_choices += [
        [ 1, 1],
        [-1,-1],
        [ 1,-1],
        [-1, 1]
        ]
    end

    move_choices.each do |(dx, dy)|
      (1..8).each do |i|
        slide = "#{NUMBER_MAP[letter_number + dx * i]}#{o_number + dy * i}"

        if (letter_number + dx * i).between?(0, 7) && (o_number + dy * i).between?(1, 8)
          if board[slide].nil?
            moves << slide
          elsif board[slide].color == self.color
            break
          else
            moves << slide
            break
          end
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

  def moves
    moves                = []
    origin               = self.pos
    o_letter             = origin[0]
    o_number             = origin[1].to_i
    letter_number        = LETTER_MAP[o_letter]

    if piece_name == :King
      move_choices     = [
        [-1, -1],
        [-1,  0],
        [-1,  1],
        [ 0,  1],
        [ 0, -1],
        [ 1, -1],
        [ 1,  0],
        [ 1,  1]
      ]
    end


    if piece_name == :Knight
      move_choices     = [
        [-2, -1],
        [-2,  1],
        [-1, -2],
        [-1,  2],
        [ 1, -2],
        [ 1,  2],
        [ 2, -1],
        [ 2,  1]
      ]
    end

    move_choices.each do |(dx, dy)|
      if (letter_number + dx).between?(0, 7) && (o_number + dy).between?(1, 8)
        slide = "#{NUMBER_MAP[letter_number + dx]}#{o_number + dy}"
        moves << slide
      end
    end

    moves
  end
end




class IllegalMoveError < StandardError
end

# test_bishop = SlidingPiece.new(:Bishop, "a1", Board.new, :black)
# test_bishop.moves.each {|move| p move}

# test_rook = SlidingPiece.new(:Rook, "a1", Board.new, :white)
# test_rook.moves.each {|move| p move}
# p test_rook.moves.include?("b2")

# test_queen = SlidingPiece.new(:Queen, "c4", Board.new, :white)
# test_queen.moves.each {|move| p move}

# test_king = SteppingPiece.new(:King, "c3", Board.new, :black)
# test_king.moves.each {|move| p move}

# test_knight = SteppingPiece.new(:Knight, "b6", Board.new, :black)
# test_knight.moves.each {|move| p move}

test_game = Chess.new
test_game.play
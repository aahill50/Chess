require 'colorize'
class Chess
  attr_reader :board

  def initialize(board  = Board.new)
    @turn = :white
    @board = board
  end

  def play
    system('clear')
    self.board.draw_board

    until board.checkmate?(:black) || board.checkmate?(:white)
      puts "#{@turn.capitalize} is in check" if board.in_check?(@turn)

      puts "#{@turn.capitalize} choose a move: b8,a6 for example".colorize(:blue).on_red
      player_move = gets.chomp.split(",")
      start_pos, end_pos = player_move[0], player_move[1]

      if valid_start?(start_pos, @turn) && valid_end?(start_pos, end_pos)
        unless self.board.move(start_pos, end_pos)
          next
        end

        system('clear')
        self.board.draw_board
        switch_turn
      end
    end

    puts "Checkmate!"
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

  attr_accessor :grid, :black_king, :white_king

  def initialize(grid = Array.new(8) {Array.new(8)})
    @grid = grid
    set_pieces
  end

  def [](pos) # =>
    letter, number = pos[0] , pos[1].to_i
    grid[8 - number][LETTER_MAP[letter]]
  end

  def []=(pos, piece)
    letter, number = pos[0] , pos[1].to_i
    grid[8 - number][LETTER_MAP[letter]] = piece
  end

  def move!(start_pos, end_pos)
    self[start_pos].pos = end_pos
    self[start_pos], self[end_pos] = nil, self[start_pos]
  end

  def move(start_pos, end_pos)
    # begin
    #   unless self[start_pos].valid_move?(start_pos, end_pos)
    #
    # rescue IllegalMoveError
    #   puts "Enter a valid move: "
    #   retry
    # end
    moving_piece = self[start_pos]

    if moving_piece.move_into_check?(start_pos, end_pos)
      puts "You can't move into check!"
      return false
    else
      #puts "You can do that"
      self[start_pos], self[end_pos] = nil, self[start_pos]
      moving_piece.pos = end_pos
    end

    true
  end



  def set_pieces#(row, team)

    self["a8"] = SlidingPiece.new(:Rook, "a8", self, :black)
    self["b8"] = SteppingPiece.new(:Knight, "b8", self, :black)
    self["c8"] = SlidingPiece.new(:Bishop, "c8", self, :black)
    self["d8"] = SlidingPiece.new(:Queen, "d8", self, :black)
    self["e8"] = SteppingPiece.new(:King, "e8", self, :black)
    self["f8"] = SlidingPiece.new(:Bishop, "f8", self, :black)
    # self["e7"] = SlidingPiece.new(:Queen, "e7", self, :black)
    self["g8"] = SteppingPiece.new(:Knight, "g8", self, :black)
    self["h8"] = SlidingPiece.new(:Rook, "h8", self, :black)
    @black_king = self['e8']

    self["a7"] = PawnPiece.new(:Pawn, "a7",self, :black)
    self["b7"] = PawnPiece.new(:Pawn, "b7",self, :black)
    self["c7"] = PawnPiece.new(:Pawn, "c7",self, :black)
    self["d7"] = PawnPiece.new(:Pawn, "d7",self, :black)
    self["e7"] = PawnPiece.new(:Pawn, "e7",self, :black)
    self["f7"] = PawnPiece.new(:Pawn, "f7",self, :black)
    self["g7"] = PawnPiece.new(:Pawn, "g7",self, :black)
    self["h7"] = PawnPiece.new(:Pawn, "h7",self, :black)


    self["a1"] = SlidingPiece.new(:Rook, "a1", self, :white)
    self["b1"] = SteppingPiece.new(:Knight, "b1", self, :white)
    self["c1"] = SlidingPiece.new(:Bishop, "c1", self, :white)
    self["d1"] = SlidingPiece.new(:Queen, "d1", self, :white)
    self["e1"] = SteppingPiece.new(:King, "e1", self, :white)
    self["f1"] = SlidingPiece.new(:Bishop, "f1", self, :white)
    self["g1"] = SteppingPiece.new(:Knight, "g1", self, :white)
    self["h1"] = SlidingPiece.new(:Rook, "h1", self, :white)
   @white_king = self['e1']

   self["a2"] = PawnPiece.new(:Pawn, "a2",self, :white)
   self["b2"] = PawnPiece.new(:Pawn, "b2",self, :white)
   self["c2"] = PawnPiece.new(:Pawn, "c2",self, :white)
   self["d2"] = PawnPiece.new(:Pawn, "d2",self, :white)
   self["e2"] = PawnPiece.new(:Pawn, "e2",self, :white)
   self["f2"] = PawnPiece.new(:Pawn, "f2",self, :white)
   self["g2"] = PawnPiece.new(:Pawn, "g2",self, :white)
   self["h2"] = PawnPiece.new(:Pawn, "h2",self, :white)
  end

  def pos(position)
    x, y = position[0], position[1]
    "#{NUMBER_MAP[y]}#{8 - x}"
  end
  # checkmate = in_check? && no valid_moves
  def checkmate?(color)
    my_king = (color == :white ? @white_king : @black_king )
    # p my_king.color
    # p my_king.moves
    # p in_check?(color)
    my_king.moves.reject{ |move| my_king.move_into_check?(my_king.pos, move)}.empty? && in_check?(color)
  end

  def in_check?(color)
    opp_team = all_pieces.select {|piece| piece.color != color}
    my_king_pos = (color == :black ? @black_king.pos : @white_king.pos)

    # p opp_team
    # p my_king_pos

    counter = 0
    opp_team.each do |piece|
      #puts "#{piece.color} - #{piece.piece_name} #{piece.moves}"
      counter += 1 if piece.moves.include?(my_king_pos)
    end
    #puts "Number #{counter}"
    counter > 0
  end

  def all_pieces
    grid.flatten.compact
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

  # Deep dup to be implemented later...
  # def deep_dup
  #   duped_board = self.clone
  #   duped_board.grid = self.grid.deep_dup
  #
  #   duped_pieces = duped_board.grid.flatten.compact
  #   duped_pieces.each do |piece|
  #     piece.dup(duped_board)
  #   end
  #
  #   duped_board
  # end
end

class Piece
  LETTER_MAP = {'a' => 0,'b' => 1,'c' => 2,'d' => 3,
                'e' => 4,'f' => 5,'g' => 6,'h' => 7 }
  NUMBER_MAP = LETTER_MAP.invert

  attr_reader :piece_name, :color
  attr_accessor :pos, :board

  def initialize(piece_name, pos, board, color)
    @piece_name = piece_name
    @pos = pos
    @board = board
    @color = color
  end

  def move_into_check?(start_pos, end_pos)
    self.board.move!(start_pos, end_pos)
    if self.board.in_check?(self.color)
      self.board.move!(end_pos, start_pos)
      return true
    end
    self.board.move!(end_pos, start_pos)
    false
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
    # {:position => pos,
    #   :class => self.class}
    pos

  end

  def same_team?(other_piece)
    self.color == other_piece.color
  end

  # def dup(new_board)
  #    self.board = new_board
  # end
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
       move_choices = [
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
        if board[slide].nil?
          moves << slide
        else
          moves << slide unless board[slide].color == self.color
        end
      end
    end

    moves
  end
end

class PawnPiece < Piece
  #Pawn
  def initialize(piece_name, pos, board, color)
    super
  end

  def moves
    moves             = []
    origin            = self.pos
    o_letter          = origin[0]
    o_number          = origin[1].to_i
    letter_number     = LETTER_MAP[o_letter]

    if color == :white
      move_choices = [[0, 1]]
      move_choices << [0, 2] if o_number == 2

      capture_choices = [
        [1, 1],
        [-1,1],
      ]
    end

    if color == :black
      move_choices = [[0, -1]]
      move_choices << [0, -2] if o_number == 7

      capture_choices = [
        [1, -1],
        [-1,-1],
      ]
    end

    move_choices.each do |(dx, dy)|
      if (letter_number + dx).between?(0, 7) && (o_number + dy).between?(1, 8)
        slide = "#{NUMBER_MAP[letter_number + dx]}#{o_number + dy}"
        moves << slide if board[slide].nil?
      end
    end

    capture_choices.each do |(dx, dy)|
      if (letter_number + dx).between?(0, 7) && (o_number + dy).between?(1, 8)
        slide         = "#{NUMBER_MAP[letter_number + dx]}#{o_number + dy}"
        if board[slide].nil?
          #Not valid for capturing
        else
          moves << slide unless board[slide].color == self.color
        end
      end
    end

    moves
  end
end

class Array
  def deep_dup
    map do |el|
      el.is_a?(Array) ? el.deep_dup : el.clone unless el.nil?
    end
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

# test_knight.valid_moves
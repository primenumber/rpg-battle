require 'curses'

$hands = ["goo", "tyoki", "par"]

class Player
  attr_accessor :hp, :at, :df
  def initialize(command_window)
    @hp = 100
    @at = 10
    @df = 10
    @command_window = command_window
  end
  def command_select_view(now_command)
    hands = ["グー","チョキ","パー"]
    hands.each.with_index do |h, i|
      @command_window.setpos(1+i, 1)
      @command_window.standout if i == now_command
      @command_window.addstr(h)
      @command_window.standend if i == now_command
    end
    @command_window.box(?#,?#,?#)
    @command_window.refresh
    Curses.refresh
  end
  def play
    now_command = 0
    loop do
      command_select_view(now_command)
      ch = Curses.getch
      case ch
      when Curses::KEY_DOWN
        if now_command < 2 then
          now_command += 1
        else
          Curses.beep
        end
      when Curses::KEY_UP
        if now_command > 0 then
          now_command -= 1 
        else
          Curses.beep
        end
      when 10
        return $hands[now_command]
      else
        Curses.addstr(ch.to_s)
        Curses.beep
      end
    end
  end
  def view
    return <<"EOS"
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
mememememememe
EOS
  end
end

class Enemy
  attr_accessor :hp, :at, :df
  def initialize
    @hp = 100
    @at = 10
    @df = 10
  end
  def play
    return ["goo", "tyoki", "par"].sample
  end
  def view
    return <<"EOS"
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
I'm an enemy.
EOS
  end
end

def win
  @enemy.hp -= @player.at
end

def draw
  @enemy.hp -= @player.at / 2
  @player.hp -= @enemy.at / 2
end

def lose
  @player.hp -= @enemy.at
end

def put_str(str, y, x)
  str.each_line.with_index do |l, i|
    Curses.setpos(y + i, x)
    Curses.addstr(l)
  end
  Curses.refresh
end

def big_str(str)
  bstr = `figlet #{str}`
  put_str(bstr, 5, Curses.cols / 2 - (bstr.split(?\n)[0].size / 2))
end

def show_status
  @status_window.clear
  @status_window.setpos(1, 1)
  @status_window.addstr("Player HP: #{@player.hp}")
  @status_window.setpos(2, 1)
  @status_window.addstr("Enemy HP: #{@enemy.hp}")
  @status_window.box(?#, ?#, ?#)
  Curses.refresh
  @status_window.refresh
end

def gameclear
  big_str("gameclear")
end

def gameover
  big_str("gameover")
end

Curses.init_screen
Curses.noecho
Curses.stdscr.keypad = true
@status_window = Curses::Window.new(5, 20, Curses.lines - 6, 2)
@command_window = Curses::Window.new(5, 20, Curses.lines - 6, 24)

@player = Player.new(@command_window)
@enemy = Enemy.new

loop do
  show_status
  command = @player.play
  enemy_command = @enemy.play
  #Curses.addstr enemy_command
  case command
  when "goo"
    case enemy_command
    when "goo"
      draw
    when "tyoki"
      win
    when "par"
      lose
    end
  when "tyoki"
    case enemy_command
    when "goo"
      lose
    when "tyoki"
      draw
    when "par"
      win
    end
  when "par"
    case enemy_command
    when "goo"
      win
    when "tyoki"
      lose
    when "par"
      draw
    end
  end
  if @player.hp <= 0 then
    gameover
    break
  elsif @enemy.hp <= 0 then
    gameclear
    break
  end
end
Curses.getch
Curses.close_screen

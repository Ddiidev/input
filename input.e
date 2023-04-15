namespace input
public include std\graphics.e

public constant
    TYPE_PASSWORD=1,
    TYPE_TEXT=0,
    UNDEFINED_LENGTH=0

constant
    BACKSPACE   = 8,
    ENTER       = 13,
    ESC         = 27,
    LEFT        = 1016384,
    RIGTH       = 1016416,
    UP          = 1016400,
    DOWN        = 1016432

--- Author  : André Luiz
--- Version : 0.0.0.1
--- Name    : input
---
--- Return  : sequence with text written 
---
--- Examples :
--- input("Write here: ")
--- input("write password here: ", TYPE_PASSWORD) -- mask *
--- input("write password here(max 4 digits): ", TYPE_PASSWORD, 4) -- mask * with max of 4 char
--- input("write username here(max 10 digits): ", TYPE_TEXT, 10) -- Max of 10 char
--- input("write here: ", TYPE_TEXT, UNDEFINED_LENGTH, {-1, graphics:RED}) -- Cursor red
---
public function input(sequence prompt="", integer type_text=TYPE_TEXT, integer length_text=UNDEFINED_LENGTH, sequence color_cursor = {-1, graphics:BRIGHT_GREEN})
    atom
        row, default_row,
        col, default_col
    integer
        key=0, cursor=0,
        fcolor, bcolor
    sequence
        text="", text_view={"", ""},
        at, cs
    
    at          = get_position()
    row         = at[1]
    col         = at[2]+length(prompt)
    default_row = row
    default_col = col
    
    cs          = console:get_screen_char(row, col, 1)
    cs          = cs[2..$]
    fcolor      = cs[1]
    bcolor      = cs[2]
    
    if (color_cursor[1] = -1) then
        color_cursor[1] = bcolor
    end if
    if (color_cursor[2] = -1) then
        color_cursor[2] = fcolor
    end if
    
    puts(1, prompt)
    while (key != ENTER) label "while-main" do
        key = wait_key()
        
        if (key >= 32) and (key <= 255) then
            if length_text > 0 then
                if (length(text) = length_text) then
                    continue "while-main"
                end if
            end if
            
            text = text[1..cursor] & sprintf("%s", key) & text[cursor+1..$]
            col += 1
            cursor += 1
        
        elsif (key = UP) then
            cursor = 1
                
        elsif (key = DOWN) then
            cursor = length(text)
            
        elsif (key = LEFT) then
            cursor -= (cursor > 0)
            
        elsif (key = RIGTH) then
            cursor += (cursor < length(text))
            
        elsif (key = BACKSPACE) and (cursor > 0) then
            text = text[1..cursor-1] & text[cursor+1..$]
            col -= 1
            cursor -= 1
        end if
        
        position(default_row, default_col)
        puts(1, join( repeat(" ", length(text)+cursor+2),"") )
        
        position(row, col-length(text))
        
        if (type_text) then
            text_view[1] = join(repeat("*", cursor), "")
            text_view[2] = join(repeat("*", length(text)-cursor), "")
        else
            text_view[1] = text[1..cursor]
            text_view[2] = text[cursor+1..$]
        end if
        
        
        graphics:bk_color(bcolor)
        graphics:text_color(fcolor)
            puts(1, text_view[1])
        
        graphics:bk_color(color_cursor[1])
        graphics:text_color(color_cursor[2])
            puts(1, "|")
        
        graphics:text_color(fcolor)
            puts(1, text_view[2])
        
    end while
    
    return text
end function

function join(sequence items, object delim=" ")
	object ret

	if not length(items) then return {} end if

	ret = {}
	for i=1 to length(items)-1 do
		ret &= items[i] & delim
	end for

	ret &= items[$]

	return ret
end function

function wait_key()
    return machine_func(26, 0)
end function

--[[
README:

Translation

goto my repository https://github.com/zhang-changwei/Automation-scripts-for-Aegisub for the latest version

Feature:
Translate the values of the tags
which means add values with equivalent inteval (or specific function relationship) to the tags of selected lines
Now \pos \fscx \fscy \[i]clip tags are supported

Manual:
1. Select the lines
2. Check the tag(s) you want to translate on the GUI and set the corresponding three values
   start: the translation value of the first line
   end:   the translation value of the last line
   accel: the gradient function (default value 1 means equivalent interval)
3. Press OK and run

Bug Report:
1. Only zero or one \pos tag can be included in one line

Updated on 9 Fre 2021
    Add "index" to accurately recognize the tag
    Add more options: frz,fsp,fsvp,frx,fry,fax,fay
    Bug Fixed

Updated on 21 Jan 2021
    Bug of position recognition fixed
    Name changed to Translation

Updated on 20 Jan 2021
    New feature (scale|clip) added

Updated on 7 Dec 2020
]]

script_name="C Translation-平移"
script_description="Trasnlation v3.2.1 - 汉化版"
script_author="chaaaaang"
script_version="3.2.1"

include("karaskel.lua")

--GUI
local dialog_config={
    {class="checkbox",name="set",label="模式选择",value=true,x=0,y=0,hint="不勾选：时间模式，勾选：行模式"},-- 英文名 setting
    {class="label",label="平移开始值",x=2,y=0},--start 选中要平移行的首行值 （英文名 Translation）
    {class="label",label="平移结束值",x=4,y=0},--end 选中要平移行的末行值（英文名 Translation）
    {class="label",label="平滑/峰值",x=6,y=0},--deviation 峰值，即特效标签数值的最大改变量 （英文名 Smooth）
    {class="label",label="平移/平滑加速",x=8,y=0},--accel 参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐 （英文名 Translation / Smooth）
    {class="label",label="平滑/峰位横移",x=10,y=0},--transverse  参数范围：0-inf，改变峰在横轴（时间、行）上的位置（英文名 Smooth）
    {class="label",label="平移/平滑标签序号",x=12,y=0},--index （英文名 Translation / Smooth）   标签位置: 标签在行中的位置。以\\bord为例：\{\\bord1\\t(\\bord2)\}你\{\\bord3\}好，有3个\\bord，需要修改那个就选相应的数字。
    --posx
    {class="checkbox",name="posx",label="posx",value=false,x=0,y=1},
    {class="label",label="posx_开始",x=1,y=1},
    {class="floatedit",name="posx_start",value=0,x=2,y=1,hint="已选中要平移行的首行值。"},--2022-08-16
    {class="label",label="posx_结束",x=3,y=1},
    {class="floatedit",name="posx_end",value=0,x=4,y=1,hint="已选中要平移行的末行值。"},--2022-08-16
    {class="label",label="峰值",x=5,y=1},
    {class="floatedit",name="posx_deviation",value=0,x=6,y=1,hint="峰高或峰值，即特效标签数值的最大改变量。"},--2022-08-16
    {class="label",label="加速度",x=7,y=1},
    {class="floatedit",name="posx_accel",value=1,x=8,y=1,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=1},
    {class="floatedit",name="posx_transverse",value=1,x=10,y=1,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    --posy
    {class="checkbox",name="posy",label="posy",value=false,x=0,y=2},
    {class="label",label="posy_开始",x=1,y=2},
    {class="floatedit",name="posy_start",value=0,x=2,y=2,hint="已选中要平移行的首行值。"},
    {class="label",label="posy_结束",x=3,y=2},
    {class="floatedit",name="posy_end",value=0,x=4,y=2,hint="已选中要平移行的末行值。"},
    {class="label",label="峰值",x=5,y=2},
    {class="floatedit",name="posy_deviation",value=0,x=6,y=2,hint="峰高或峰值，即特效标签数值的最大改变量。"},--2022-08-16
    {class="label",label="加速度",x=7,y=2},
    {class="floatedit",name="posy_accel",value=1,x=8,y=2,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=2},
    {class="floatedit",name="posy_transverse",value=1,x=10,y=2,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    --fscx
    {class="checkbox",name="fscx",label="fscx",value=false,x=0,y=3},
    {class="label",label="fscx_开始",x=1,y=3},
    {class="floatedit",name="fscx_start",value=0,x=2,y=3,hint="已选中要变换行的首行值。"},
    {class="label",label="fscx_结束",x=3,y=3},
    {class="floatedit",name="fscx_end",value=0,x=4,y=3,hint="已选中要变换行的末行值。"},
    {class="label",label="峰值",x=5,y=3},
    {class="floatedit",name="fscx_deviation",value=0,x=6,y=3,hint="峰高或峰值，即特效标签数值的最大改变量。"},
    {class="label",label="加速度",x=7,y=3},
    {class="floatedit",name="fscx_accel",value=1,x=8,y=3,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=3},
    {class="floatedit",name="fscx_transverse",value=1,x=10,y=3,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    {class="label",label="标签序号",x=11,y=3},
    {class="intedit",name="fscx_index",value=1,x=12,y=3,hint="标签位置: 标签在行中的位置。以\\bord为例：{\\bord1\\t(\\bord2)}你{\\bord3}好，有3个\\bord，需要修改那个就选相应的数字。"},
    --fscy
    {class="checkbox",name="fscy",label="fscy",value=false,x=0,y=4},
    {class="label",label="fscy_开始",x=1,y=4},
    {class="floatedit",name="fscy_start",value=0,x=2,y=4,hint="已选中要变换行的首行值。"},
    {class="label",label="fscy_结束",x=3,y=4},
    {class="floatedit",name="fscy_end",value=0,x=4,y=4,hint="已选中要平变换的末行值。"},
    {class="label",label="峰值",x=5,y=4},
    {class="floatedit",name="fscy_deviation",value=0,x=6,y=4,hint="峰高或峰值，即特效标签数值的最大改变量。"},
    {class="label",label="加速度",x=7,y=4},
    {class="floatedit",name="fscy_accel",value=1,x=8,y=4,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=4},
    {class="floatedit",name="fscy_transverse",value=1,x=10,y=4,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    {class="label",label="标签序号",x=11,y=4},
    {class="intedit",name="fscy_index",value=1,x=12,y=4,hint="标签位置: 标签在行中的位置。以\\bord为例：{\\bord1\\t(\\bord2)}你{\\bord3}好，有3个\\bord，需要修改那个就选相应的数字。"},
    --frz
    {class="checkbox",name="frz",label="frz",value=false,x=0,y=5},
    {class="label",label="frz_开始",x=1,y=5},
    {class="floatedit",name="frz_start",value=0,x=2,y=5,hint="已选中要变换行的首行值。"},
    {class="label",label="frz_结束",x=3,y=5},
    {class="floatedit",name="frz_end",value=0,x=4,y=5,hint="已选中要变换行的末行值。"},
    {class="label",label="峰值",x=5,y=5},
    {class="floatedit",name="frz_deviation",value=0,x=6,y=5,hint="峰高或峰值，即特效标签数值的最大改变量。"},--2022-08-16
    {class="label",label="加速度",x=7,y=5},
    {class="floatedit",name="frz_accel",value=1,x=8,y=5,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=5},
    {class="floatedit",name="frz_transverse",value=1,x=10,y=5,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    {class="label",label="标签序号",x=11,y=5},
    {class="intedit",name="frz_index",value=1,x=12,y=5,hint="标签位置: 标签在行中的位置。以\\bord为例：{\\bord1\\t(\\bord2)}你{\\bord3}好，有3个\\bord，需要修改那个就选相应的数字。"},
    --clip_x
    {class="checkbox",name="clip_x",label="clip_x",value=false,x=0,y=6},
    {class="label",label="clip_x_开始",x=1,y=6},
    {class="floatedit",name="clip_x_start",value=0,x=2,y=6,hint="已选中要平移行的首行值。"},
    {class="label",label="clip_x_结束",x=3,y=6},
    {class="floatedit",name="clip_x_end",value=0,x=4,y=6,hint="已选中要平移行的末行值。"},
    {class="label",label="峰值",x=5,y=6},
    {class="floatedit",name="clip_x_deviation",value=0,x=6,y=6,hint="峰高或峰值，即特效标签数值的最大改变量。"},
    {class="label",label="加速度",x=7,y=6},
    {class="floatedit",name="clip_x_accel",value=1,x=8,y=6,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=6},
    {class="floatedit",name="clip_x_transverse",value=1,x=10,y=6,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    --clip_y
    {class="checkbox",name="clip_y",label="clip_y",value=false,x=0,y=7},
    {class="label",label="clip_y_开始",x=1,y=7},
    {class="floatedit",name="clip_y_start",value=0,x=2,y=7,hint="已选中要平移行的首行值。"},
    {class="label",label="clip_y_结束",x=3,y=7},
    {class="floatedit",name="clip_y_end",value=0,x=4,y=7,hint="已选中要平移行的末行值。"},
    {class="label",label="峰值",x=5,y=7},
    {class="floatedit",name="clip_y_deviation",value=0,x=6,y=7,hint="峰高或峰值，即特效标签数值的最大改变量。"},
    {class="label",label="加速度",x=7,y=7},
    {class="floatedit",name="clip_y_accel",value=1,x=8,y=7,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=7},
    {class="floatedit",name="clip_y_transverse",value=1,x=10,y=7,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    --other
    {class="checkbox",name="other_button",label="其他 标签",value=false,x=0,y=8},
    {class="dropdown",name="other",items={"fsp","fsvp","fax","fay","frx","fry"},x=0,y=9},
    {class="label",label="其他_开始",x=1,y=9},
    {class="floatedit",name="other_start",value=0,x=2,y=9,hint="已选中要变换行的首行值。"},
    {class="label",label="其他_结束",x=3,y=9},
    {class="floatedit",name="other_end",value=0,x=4,y=9,hint="已选中要变换行的首行值。"},
    {class="label",label="峰值",x=5,y=9},
    {class="floatedit",name="other_deviation",value=0,x=6,y=9,hint="峰高或峰值，即特效标签数值的最大改变量。"},--2022-08-16
    {class="label",label="加速度",x=7,y=9},
    {class="floatedit",name="other_accel",value=1,x=8,y=9,hint="平移：accel=1,匀速偏移;accel>1,先慢后快;accel<1,先快后慢;\n平滑：参数范围：0-inf，改变峰宽，该参数越大，峰越尖锐。"},
    {class="label",label="峰位横移",x=9,y=9},
    {class="floatedit",name="other_transverse",value=1,x=10,y=9,hint="参数范围：0-inf，改变峰在横轴（时间、行）上的位置。"},
    {class="label",label="标签序号",x=11,y=9},
    {class="intedit",name="other_index",value=1,x=12,y=9,hint="标签位置: 标签在行中的位置。以\\bord为例：{\\bord1\\t(\\bord2)}你{\\bord3}好，有3个\\bord，需要修改那个就选相应的数字。"},
    --multiply
    {class="checkbox",name="XeqY",label="fscy<-fscx",value=false,x=2,y=10},
    {class="checkbox",name="multiply",label="乘法模式",width=2,value=false,x=3,y=10},
    --note
    {class="label",x=0,y=10,width=2,label="Translation v3.2.1"},
    {class="label",x=0,y=11,width=13,label="最顶行的参数名称中有平移的，则参数只能应用于平移功能（平移按钮）；有平移/平滑的，则参数对两者均适用。\n最好在逐帧行（一帧一行）中使用，可以先使用Relocator中的linetofbf，索引参数Z+ 。"},
    {class="label",x=0,y=12,width=13,label="标签位置: 标签在行中的位置。以\\bord为例：{\\bord1\\t(\\bord2)}你{\\bord3}好，有3个\\bord，需要修改那个就选相应的数字。"},
    {class="label",x=0,y=13,width=13,label="注意：正posy表示向下移动，负posy表示向上移动。"},
    {class="label",x=0,y=14,width=13,label="平移函数: (tail-head)*x^a+head   平滑函数: ((1-cos(x^t))/2)^a*deviation 。"},
    {class="label",x=0,y=15,width=13,label="加速度：参数范围（0，inf）平滑峰值随着参数的增加而变得更尖锐。"},
    {class="label",x=0,y=16,width=13,label="峰位横移：参数范围（0，inf） 与中心的横向偏差，随着参数的增加，峰值从左向右移动。\n\n     平移按钮          平滑按钮           退出按钮"}
}
local buttons={"Translation","Smooth","Quit"}

function main(subtitle, selected, active)
    local meta,styles=karaskel.collect_head(subtitle,false)
    local xres, yres, ar, artype = aegisub.video_size()

    --count the size N,T
    local start_f,end_f = 0,0

    for sa,la in ipairs(selected) do
        local line = subtitle[la]
        if (sa == 1) then start_f = aegisub.frame_from_ms(line.start_time) end
        end_f = aegisub.frame_from_ms(line.start_time)
    end
    local T = end_f - start_f + 1
    local N = #selected

    local pressed, result = aegisub.dialog.display(dialog_config,buttons)
    if (pressed=="Quit") then aegisub.cancel() end
    --all false
    if (result["posx"]==false and result["posy"]==false and result["fscx"]==false and result["fscy"]==false and result["clip_x"]==false and result["clip_y"]==false and result["frz"]==false and result["other_button"]==false) then
        aegisub.cancel()
    else
        if result.XeqY==true then
            result.fscy = true
            result.fscy_start, result.fscy_end, result.fscy_accel, result.fscy_deviation, result.fscy_transverse, result.fscy_index
            = result.fscx_start, result.fscx_end, result.fscx_accel, result.fscx_deviation, result.fscx_transverse, result.fscx_index
        end
        --loop begins
        local i = 0
        for si,li in ipairs(selected) do
            i = i + 1
            local line=subtitle[li]
            local now_f = aegisub.frame_from_ms(line.start_time)
            local t = now_f - start_f + 1
            karaskel.preproc_line(subtitle,meta,styles,line)
            --preprocession
            local linetext = (line.text:match("^{")==nil) and "{}"..line.text or line.text
            linetext = linetext:gsub("}{","")

            --posx posy
            if (result["posx"]==true or result["posy"]==true) then
                --confirm the \pos is in the tag
                if (linetext:match("^{[^}]*\\pos[^}]*}")==nil) then
                    if (linetext:match("\\an%d")==nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",line.x,line.y))
                    elseif (linetext:match("\\an1")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",line.styleref.margin_l,yres-line.styleref.margin_b))
                    elseif (linetext:match("\\an2")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres/2,yres-line.styleref.margin_b))
                    elseif (linetext:match("\\an3")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres-line.styleref.margin_r,yres-line.styleref.margin_b))
                    elseif (linetext:match("\\an4")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",line.styleref.margin_l,yres/2))
                    elseif (linetext:match("\\an5")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres/2,yres/2))
                    elseif (linetext:match("\\an6")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres-line.styleref.margin_r,yres/2))
                    elseif (linetext:match("\\an7")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",line.styleref.margin_l,line.styleref.margin_t))
                    elseif (linetext:match("\\an8")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres/2,line.styleref.margin_t))
                    elseif (linetext:match("\\an9")~=nil) then
                        linetext=linetext:gsub("^{",string.format("{\\pos(%.3f,%.3f)",xres-line.styleref.margin_r,line.styleref.margin_t))
                    else
                    end
                end

                if (result["posx"]==true) then
                    local gposx = linetext:match("\\pos%([^,]*")
                    gposx = tonumber(gposx:sub(6))
                    linetext=linetext:gsub("\\pos%([^,]*,",string.format("\\pos(%.3f,", gposx + interpolate(result["posx_start"],result["posx_end"],result["posx_accel"],N,T,i,t,result["set"],result["posx_deviation"],result["posx_transverse"],pressed)))
                end
                if (result["posy"]==true) then
                    local gpx, gpy = linetext:match("\\pos%(([^,]*),([^%)]*)%)")
                    gpy = tonumber(gpy)+interpolate(result["posy_start"],result["posy_end"],result["posy_accel"],N,T,i,t,result["set"],result["posy_deviation"],result["posy_transverse"],pressed)
                    linetext=linetext:gsub("\\pos%(([^,]*),[^%)]*%)",string.format("\\pos(%s,%.3f)",gpx,gpy))
                end
            end
            --fscx
            if (result["fscx"]==true) then
                if (linetext:match("\\fscx")==nil) then
                    linetext=linetext:gsub("^{",string.format("{\\fscx%.2f",line.styleref.scale_x))
                end
                local deviation = interpolate(result["fscx_start"],result["fscx_end"],result["fscx_accel"],N,T,i,t,result["set"],result["fscx_deviation"],result["fscx_transverse"],pressed)
                linetext = translation(linetext,"\\fscx",deviation,result["fscx_index"],"([^}]*)}\\fscx([%d%.%-]+)","\\fscx[%d%.%-]+$",result["multiply"])
            end
            --fscy
            if (result["fscy"]==true) then
                if (linetext:match("\\fscy")==nil) then
                    linetext=linetext:gsub("^{",string.format("{\\fscy%.2f",line.styleref.scale_y))
                end
                local deviation = interpolate(result["fscy_start"],result["fscy_end"],result["fscy_accel"],N,T,i,t,result["set"],result["fscy_deviation"],result["fscy_transverse"],pressed)
                linetext = translation(linetext,"\\fscy",deviation,result["fscy_index"],"([^}]*)}\\fscy([%d%.%-]+)","\\fscy[%d%.%-]+$",result["multiply"])
            end
            --frz
            if (result["frz"]==true) then
                if (linetext:match("\\frz")==nil) then
                    linetext=linetext:gsub("^({[^}]*)}",function (a) return string.format("%s\\frz%.2f}",a,line.styleref.angle) end)
                end
                local deviation = interpolate(result["frz_start"],result["frz_end"],result["frz_accel"],N,T,i,t,result["set"],result["frz_deviation"],result["frz_transverse"],pressed)
                linetext = translation(linetext,"\\frz",deviation,result["frz_index"],"([^}]*)}\\frz([%d%.%-]+)","\\frz[%d%.%-]+$")
            end
            --clip
            if (result["clip_x"]==true or result["clip_y"]==true) then
                linetext = linetext:gsub("(\\[i]?clip)([^%)]+)%)",
                    function(c,d)
                        --odd or even xyxy
                        local o_e=0
                        local trs_clip = c
                        for head,num in d:gmatch("([^%d%.%-]+)([%d%.%-]+)") do
                            if (o_e == 0 and result["clip_x"]==true) then
                                trs_clip = string.format("%s%s%.2f",trs_clip,head,num+interpolate(result["clip_x_start"],result["clip_x_end"],result["clip_x_accel"],N,T,i,t,result["set"],result["clip_x_deviation"],result["clip_x_transverse"],pressed))
                            elseif (o_e == 1 and result["clip_y"]==true) then
                                trs_clip = string.format("%s%s%.2f",trs_clip,head,num+interpolate(result["clip_y_start"],result["clip_y_end"],result["clip_y_accel"],N,T,i,t,result["set"],result["clip_y_deviation"],result["clip_y_transverse"],pressed))
                            else
                                trs_clip = string.format("%s%s%.2f",trs_clip,head,num)
                            end
                            o_e = (o_e + 1)%2
                        end
                        return trs_clip..")"
                    end)
            end
            --other tags
            if (result["other_button"]==true) then
                --fsp
                if (result["other"]=="fsp") then
                    if (linetext:match("\\fsp")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return string.format("%s\\fsp%.2f}",a,line.styleref.spacing) end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\fsp",deviation,result["other_index"],"([^}]*)}\\fsp([%d%.%-]+)","\\fsp[%d%.%-]+$")
                --fsvp
                elseif (result["other"]=="fsvp") then
                    if (linetext:match("\\fsvp")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return a.."\\fsvp0}" end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\fsvp",deviation,result["other_index"],"([^}]*)}\\fsvp([%d%.%-]+)","\\fsvp[%d%.%-]+$")
                --fax
                elseif (result["other"]=="fax") then
                    if (linetext:match("\\fax")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return a.."\\fax0}" end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\fax",deviation,result["other_index"],"([^}]*)}\\fax([%d%.%-]+)","\\fax[%d%.%-]+$")
                --fay
                elseif (result["other"]=="fay") then
                    if (linetext:match("\\fay")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return a.."\\fay0}" end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\fay",deviation,result["other_index"],"([^}]*)}\\fay([%d%.%-]+)","\\fay[%d%.%-]+$")
                --frx
                elseif (result["other"]=="frx") then
                    if (linetext:match("\\frx")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return a.."\\frx0}" end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\frx",deviation,result["other_index"],"([^}]*)}\\frx([%d%.%-]+)","\\frx[%d%.%-]+$")
                --fry
                elseif (result["other"]=="fry") then
                    if (linetext:match("\\fry")==nil) then
                        linetext=linetext:gsub("^({[^}]*)}",function (a) return a.."\\fry0}" end)
                    end
                    local deviation = interpolate(result["other_start"],result["other_end"],result["other_accel"],N,T,i,t,result["set"],result["other_deviation"],result["other_transverse"],pressed)
                    linetext = translation(linetext,"\\fry",deviation,result["other_index"],"([^}]*)}\\fry([%d%.%-]+)","\\fry[%d%.%-]+$")
                end
            end
            --more feature (gradient|smooth) coming
            line.text = linetext
            line.actor = "C"
            subtitle[li] = line
        end
        --loop ends
    end
    aegisub.set_undo_point(script_name)
    return selected
end

function interpolate(head,tail,accel,N,T,i,t,judge,deviation,transverse,button)
    -- i 1-N
    local bias, x
    if (button=="Translation") then
        if (judge==false) then
            bias = (1/(N-1)*(i-1))^accel
        else
            bias = (1/(T-1)*(t-1))^accel
        end
        return (tail-head)*bias+head
    elseif (button=="Smooth") then
        if (judge==false) then
            -- ((1-cos(x^t))/2)^a*deviation
            x = 2*(i-1)* math.pi/(N-1)
        else
            x = 2*(t-1)* math.pi/(T-1)
        end
        bias = ((1-math.cos(x^transverse))/2)^accel*deviation
        return bias
    else
        return 0
    end

end

function translation(linetext,tagtype,deviation,index,match,matchtail,multiply)
    local tt_table={}
    for tg,tx in linetext:gmatch("({[^}]*})([^{]*)") do
        table.insert(tt_table,{tag=tg,text=tx})
    end

    local rebuild = ""
    local count = 0
    for _,tt in ipairs(tt_table) do
        if (tt.tag:match(tagtype)==nil) then
            rebuild = rebuild..tt.tag..tt.text
        else
            tt.tag = tt.tag:gsub(tagtype,"}"..tagtype)
            tt.tag = tt.tag..tagtype.."0"
            local rebuild_tag = ""

            for p,q in tt.tag:gmatch(match) do
                count = count + 1
                if (count == index) then
                    if multiply~=true then
                        rebuild_tag = string.format("%s%s%s%.3f",rebuild_tag,p,tagtype,q+deviation)
                    else
                        rebuild_tag = string.format("%s%s%s%.3f",rebuild_tag,p,tagtype,q*deviation)
                    end
                else
                    rebuild_tag = rebuild_tag..p..tagtype..q
                end
            end
            rebuild_tag = rebuild_tag:gsub(matchtail,"}")
            rebuild = rebuild..rebuild_tag..tt.text
            count = count - 1
        end
    end
    return rebuild
end

--This optional function lets you prevent the user from running the macro on bad input
function macro_validation(subtitle, selected, active)
    --Check if the user has selected valid lines
    --If so, return true. Otherwise, return false
    return true
end

--This is what puts your automation in Aegisub's automation list
aegisub.register_macro(script_name,script_description,main,macro_validation)
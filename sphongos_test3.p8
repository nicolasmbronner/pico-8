pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- sphongos
-- par michael koloch

-- savegame 0=off, 1=on, 2..=unlock

u_ox=1     -- ox capacity
u_sp=0     -- speed boost
u_ht=0     -- heat res
u_rd=0     -- rad res
u_ma=0     -- case cap
u_sl=0     -- case slots
u_ls=1     -- laser str
u_rk=0     -- rock dissolve
u_mt=0     -- metal cut

-- upgrades
s_up={}    -- suit
ox_up={40,50,60,70,80,99}
c_up={}    -- case
ma_up={8,16,32,48,64,99}
sl_up={1,2,3}
t_up={}    -- tool
ls_up={1,2,4,6,8,10}

music_on=true

-- actors
act={}     -- actors
spn={}     -- spawns
prt={}     -- particles

-- player
dx=1 dy=0
pl_x=20 pl_y=15
pl_sp=1

blk_x=false
blk_y=false

stp_t=0
stp_sp=9

in_ht=false
in_rd=false
dmg_e_t=0
dmg_t=0

-- death
dth_d=150
dth_t=dth_d*0.4
in_dth=true

-- oxygen
ox_t=20
ox_m=20
ox_p=0
ox_c=11

-- case
ma_m=6
mat={}
obj={}
col_ma={}
ma_sl=1
ma_tot={}
ma_plt=nil
ma_qrz=nil
ma_fn4=nil

-- tool
to_x=0
to_y=0

-- target
t_k=nil
t_x=0
t_y=0

-- laser
ls_t=false
ls_s=1
ls_b=0
ls_tm=0
ls_p=0
lst_x=0
lst_y=0

-- ui colors
s_col=11
c_col=9
t_col=10

-- upgrades
inf_t=0
inf_sp=0.6
inf_cur=inf_sp
inf_sw=false

-- analysis
anl_d=1.8
anl_blp=true

-- messages
cm_msg={}
sc_msg={}
in_msg=false
aval_mg={}
cur_msg=1
new_cm=true
new_sc=true

-- panel
txts={}
u_cx=0
in_up=false
in_sci=false
nt_on=false
nt_t=0
nt_s=""
nt_l=0
nt_c=7

-- scanline
lst_l=0
off=0

-- map
was_lab=true

-- logo
show_logo=true

function debug()
 dth_t=dth_d*0.99
 dset(31,1) dset(32,1) dset(33,1) dset(43,1)
 dset(34,1) dset(35,1) dset(41,1) dset(42,1)
 dset(1,6) dset(3,2) dset(6,2) dset(7,2)
 dset(8,6) dset(9,3) dset(10,6) dset(11,2) dset(12,2)
 dset(21,99) dset(22,99) dset(23,99) dset(24,99) dset(25,99)
end

function mk_act(k,x,y)
 a={
  k=k,
  x=x+0.5,
  y=y+0.5,
  dx=0,dy=0,
  fr=0.30,
  bc=0.1,
  w=0.4,
  h=0.4,
  frm=0,
  frms=2,
  fr_s=0.2,
  t=0,
  drp=64
 }
 add(act,a)
 return a
end

function mk_pl(k,x,y)
 mk_act(k,x,y)
 a.frms=4
 a.w=0.2
 a.h=0.2
 a.off_y=3
 a.fr_s=0.225*pl_sp
 a.bc=0
 return a
end

function mk_spn(k,x,y)
 s={k=k,x=x,y=y}
 add(spn,s)
 return s
end

function del_save()
 for i=0,63 do
  dset(i,0)
 end
 run()
end

function save_col_mat()
 dset(21,ma_tot[1].amt)
 dset(22,ma_tot[2].amt)
 dset(23,ma_tot[3].amt)
 dset(24,ma_tot[4].amt)
 dset(25,ma_tot[5].amt)

 for i=1,5 do
  if dget(i+20)>0 then
   dset(i+30,1)
   ma_tot[i].disc=true
  end
 end

 upd_upgrades()
end

function load_save()
 if(dget(0)!=0)music_on=false

 if(dget(21)!=0)ma_tot[1].amt=dget(21)
 if(dget(22)!=0)ma_tot[2].amt=dget(22)
 if(dget(23)!=0)ma_tot[3].amt=dget(23)
 if(dget(24)!=0)ma_tot[4].amt=dget(24)
 if(dget(25)!=0)ma_tot[5].amt=dget(25)

 if(dget(31)!=0)ma_tot[1].disc=true
 if(dget(32)!=0)ma_tot[2].disc=true
 if(dget(33)!=0)ma_tot[3].disc=true
 if(dget(34)!=0)ma_tot[4].disc=true
 if(dget(35)!=0)ma_tot[5].disc=true
 
 if(dget(41)!=0)ma_plt.disc=true
 if(dget(42)!=0)ma_qrz.disc=true
 if(dget(43)!=0)ma_fn4.disc=true

 upd_upgrades()
 
 dset(1,u_ox)
 dset(3,u_sp)
 dset(6,u_ht)
 dset(7,u_rd)
 
 dset(8,u_ma)
 dset(9,u_sl)
 
 dset(10,u_ls)
 dset(11,u_rk)
 dset(12,u_mt)
end

function upd_upgrades()
 if(dget(1)!=0)u_ox=dget(1)
 if(dget(3)!=0)u_sp=dget(3)
 if(dget(6)!=0)u_ht=dget(6)
 if(dget(7)!=0)u_rd=dget(7)
 if(dget(8)!=0)u_ma=dget(8)
 if(dget(9)!=0)u_sl=dget(9)
 if(dget(10)!=0)u_ls=dget(10)
 if(dget(11)!=0)u_rk=dget(11)
 if(dget(12)!=0)u_mt=dget(12)

 ox_m=ox_up[u_ox]
 ma_m=ma_up[u_ma>0 and u_ma or 1]
 ls_s=ls_up[u_ls]
 ma_sl=sl_up[max(u_sl,1)]
 pl_sp=u_sp>=2 and 1.2 or 1

 if(s_up[1]!=nil)foreach(s_up,disc_up)
 if(c_up[1]!=nil)foreach(c_up,disc_up)
 if(t_up[1]!=nil)foreach(t_up,disc_up)
end

function unlock_up(u,m)
 if m.tag==u.unlk then
  u.disc=true
  if(u.st==0)u.st=1
  if(dget(u.data)==0)dset(u.data,1)
 end
end

function disc_up(u)
 for t in all(ma_tot) do
  if t.disc then
   unlock_up(u,t)
  end
 end

 if(ma_plt.disc)unlock_up(u,ma_plt)
 if(ma_qrz.disc)unlock_up(u,ma_qrz)
end

function add_up(cat,name,info,st,data,cost,unlk,icon,col)
 u={
  name=name or "no_name",
  info=info or "missing info!",
  st=st,
  pre=false,
  data=data,
  cost=cost or {0},
  icon=icon or "▮",
  col=col or 7,
  unlk=unlk or "_",
  disc=false,
 }
 add(cat,u)
 return u
end

function gen_upgrades()
 u=add_up(s_up,"oxygen capacity:"..ox_up[2],"increases o2 tank",u_ox,1,{5,0,0})
 u.st=u_ox>1 and 2 or 1
 u.col=11
 u.disc=true
 u=add_up(s_up,"oxygen capacity:"..ox_up[3],"increases o2 tank",u_ox,1,{10,5,0})
 u.pre=true
 u.disc=true
 u.st=u_ox>2 and 2 or 1 
 u.col=11
 u=add_up(s_up,"oxygen capacity:"..ox_up[4],"increases o2 tank",u_ox,1,{0,20,10},"fungi3")
 u.pre=true
 u.st=u_ox>3 and 2 or 1
 u.col=11
 u=add_up(s_up,"oxygen capacity:"..ox_up[5],"increases o2 tank",u_ox,1,{0,40,20,10},"fungi3")
 u.pre=true
 u.st=u_ox>4 and 2 or 1
 u.col=11
 u=add_up(s_up,"oxygen capacity:"..ox_up[6],"increases o2 tank",u_ox,1,{0,60,30,0,5},"fungi3")
 u.pre=true
 u.st=u_ox>5 and 2 or 1
 u.col=11

 add_up(s_up,"ceramic plating","withstands heat",u_ht,6,{0,15,0,20},"rock1","c",11)
 add_up(s_up,"lightweight fabric","increases move speed",u_sp,3,{0,25,10},"plant1","l",11)
 add_up(s_up,"graded-z shielding","withstands radiation",u_rd,7,{0,0,15,0,20},"metal1","z",11)

 u=add_up(c_up,"case capacity:"..ma_up[2],"stores more samples",u_ma,8,{10,5,0},"fungi1")
 u.st=u_ma>1 and 2 or 1
 u.col=9
 u=add_up(c_up,"case capacity:"..ma_up[3],"stores more samples",u_ma,8,{15,10,0},"fungi1")
 u.st=u_ma>2 and 2 or 1
 u.pre=true
 u.col=9
 u=add_up(c_up,"case capacity:"..ma_up[4],"stores more samples",u_ma,8,{5,20,5},"fungi3")
 u.st=u_ma>3 and 2 or 1
 u.pre=true
 u.col=9
 u=add_up(c_up,"case capacity:"..ma_up[5],"stores more samples",u_ma,8,{60,30,10},"fungi3")
 u.st=u_ma>4 and 2 or 1
 u.pre=true
 u.col=9
 u=add_up(c_up,"case capacity:"..ma_up[6],"stores more samples",u_ma,8,{0,60,20,0,5},"metal1")
 u.st=u_ma>5 and 2 or 1
 u.pre=true
 u.col=9

 u=add_up(c_up,"sample slots:"..sl_up[2],"stores up to 2 types",u_sl,9,{0,5,0,5},"quartz1")
 u.st=u_sl>1 and 2 or 1
 u.col=9
 u=add_up(c_up,"sample slots:"..sl_up[3],"stores up to 3 types",u_sl,9,{0,0,5,5},"quartz1")
 u.st=u_sl>2 and 2 or 1
 u.pre=true
 u.col=9 

 u=add_up(t_up,"blast velocity:"..ls_up[2],"breaks target faster",u_ls,10,{10,5,0},"fungi2")
 u.st=u_ls>1 and 2 or 1
 u.col=10
 u=add_up(t_up,"blast velocity:"..ls_up[3],"breaks target faster",u_ls,10,{20,10,5},"fungi3")
 u.st=u_ls>2 and 2 or 1
 u.pre=true
 u.col=10
 u=add_up(t_up,"blast velocity:"..ls_up[4],"breaks target faster",u_ls,10,{30,15,10},"fungi3")
 u.st=u_ls>3 and 2 or 1
 u.pre=true
 u.col=10
 u=add_up(t_up,"blast velocity:"..ls_up[5],"breaks target faster",u_ls,10,{60,0,15,5},"fungi3")
 u.st=u_ls>4 and 2 or 1
 u.pre=true
 u.col=10
 u=add_up(t_up,"blast velocity:"..ls_up[6],"breaks target faster",u_ls,10,{0,0,60,15,5},"metal1")
 u.st=u_ls>5 and 2 or 1
 u.pre=true
 u.col=10

 add_up(t_up,"enzyme injector","dissolves stone",u_rk,11,{30,15,0},"fungi2","e",10)
 add_up(t_up,"co2 resonator","cuts metal",u_mt,12,{0,60,30},"fungi3","r",10)

 upd_upgrades()
end

function can_buy(u)
 for i=1,#u.cost do
  if ma_tot[i].amt<u.cost[i] then
   return false
  end
 end
 return true
end

function apply_up(cat,v)
 function up()
  sfx(12)
  dset(u.data,dget(u.data)+1)
  u.st=2
  upd_upgrades()
 end
 
 function use_mat(u)
  for i=1,#u.cost do
   ma_tot[i].amt-=u.cost[i]
  end
  save_col_mat()
 end

 u=cat[v]

 if can_buy(u) then
  if(u.pre) then
   if(cat[v-1]!=nil and cat[v-1].st==2) then
    up()
    use_mat(u)
   end
  else
   up()
   use_mat(u)
  end
 end
end

function _init()
 printh("picomush","log",true)
 cartdata("mk_picomush_sg") 
 --debug()

 setup_ma_tot()
 setup_special_ma()
 load_save()
 gen_upgrades()
 poke(0x5f36,0x40)
 poke(0x5f5c,255)

 setup_mat()
 setup_obj()
 setup_cm_msg()
 setup_sc_msg()
 upd_msgs()
 sfx(26)

 pl=mk_pl(32,pl_x,pl_y)   
 spawn_act()
end

function spawn_act()
 for i=0,127 do
  for j=0,31 do
   local k=mget(i,j)
   if fget(k,7) then
    mk_act(k,i,j)
    mset(i,j,0)
   end
  end
 end
 
 for s in all(spn) do
  mk_act(s.k,s.x,s.y)
 end
end

function rem_all_act()
 foreach(act,rem_act)
end

function rem_act(a)
 if(a!=pl)del(act,a)
end

function solid(x,y)
 val=mget(x,y)
 return fget(val,1)
end

function solid_area(x,y,w,h)
 return
  solid(x-w-0.1,y-h) or
  solid(x+w,y-h-0.1) or
  solid(x-w,y+h) or
  solid(x+w,y+h)
end

function solid_act(a,dx,dy)
 for actor in all(act) do
  if actor!=a then
   local x=(a.x+dx)-actor.x
   local y=(a.y+dy)-actor.y
   
   if((abs(x)<(a.w+actor.w)) and
      (abs(y)<(a.h+actor.h))) then

    if(dx!=0 and abs(x)<abs(a.x-actor.x))then
     local ca=col_event(a,actor) or col_event(actor,a)
     return not ca
    end
    
    if(dy!=0 and abs(y)<abs(a.y-actor.y))then
     local ca=col_event(a,actor) or col_event(actor,a)
     return not ca
    end
   end
  end    
 end  
 return false 
end

function solid_a(a,dx,dy)
 if solid_area(a.x+dx,a.y+dy,a.w,a.h) then
  return true 
 end
  
 return solid_act(a,dx,dy)
end

function col_event(a1,a2)
 if a1==pl then
  local m=find_mat(a2.k)
  if(m!=nil) then
   if collect_mat(m.tag,1) then
    del(act,a2)
    sfx(3)
    for i=1,3 do
     mk_prt(7,10+rnd(11),a2.x*8-1+rnd(3),a2.y*8-2,0,-1-rnd(3),0.6)
    end
   end
   return true
  end
 end
 
 if a1==pl and a2.k==38 then
  ox_t-=2
  local d_dx=sgn(pl.x-a2.x)
  local d_dy=sgn(pl.y-a2.y)
  pl.dx=d_dx*0.1
  pl.dy=d_dy*0.1
  return true
 end
 return true
end

function move_act(a)
 if not solid_a(a,a.dx,0) then
  a.x+=a.dx
 else
  a.dx*=-a.bc
 end
 
 if not solid_a(a,0,a.dy) then
  a.y+=a.dy
 else
  a.dy*=-a.bc
 end
 
 a.dx*=(1-a.fr)
 a.dy*=(1-a.fr)
 
 if(abs(a.dx)<0.001)a.dx=0
 if(abs(a.dy)<0.001)a.dy=0
 
 if a.k==32 then
  cur_stp=stp_sp/(u_sp>=2 and 1.2 or 1)

  if(abs(a.dx)<=0.01 and abs(a.dy)<=0.01) then
   a.frm=0
   stp_t=0
  else
   a.frm+=a.fr_s
   a.frm%=a.frms

   if(stp_t<=0) then
    if pl_in_lab() then
     sfx(21)
    else
     sfx(20)
     mk_prt(5,90+rnd(11),a.x*8-1+flr(rnd(2)),a.y*8+flr(rnd(2)),0,0,0)

     p_c=in_ht and 9 or in_rd and 11 or u_sp>=2 and 6 or 5
     for i=1,5 do
      mk_prt(p_c,30+rnd(11),a.x*8-0.3+flr(rnd(0.7)),a.y*8+flr(rnd(1)),-0.25+rnd(0.51),-rnd(0.3),0.9)
     end
    end
    
    stp_t=cur_stp
   end
   stp_t-=1
  end
 end
 
 if(a.y>=24) then
  a.x=flr(a.x)+64.5
  a.y=a.y-24
 end

 if(a.y<0) then
  a.x=flr(a.x)-63.5
  a.y=a.y+24
 end 
 
 a.t+=1
end

function brk_st(x,y,o)
 if(lst_x==x) and (lst_y==y) then
  ls_b+=ls_s
  ls_p=ls_b/o.res
  sfx(5)
  if ls_b>=o.res then
   ls_b=0
   ls_p=0
   return true
  else
   return false
  end
 else
  ls_b=0
  lst_x=x
  lst_y=y
  return false
 end
end

function targ_valid(k)
 local o=get_obj(k)
 if o.up_lvl<=u_ls then
  if o.need_rk then
   if u_rk>=2 then
    return true
   else
    return false
   end
  elseif o.need_mt then
   if u_mt>=2 then
    return true
   else
    return false
   end
  else
   return true
  end
 end
 return false
end

function get_obj(k)
 for o in all(obj) do
  if o.k==k then
   return o
  end
 end
end

function get_mat(k)
 for m in all(mat) do
  if m.k==k then
   return m
  end
 end
end

function fire_laser()
 local o=get_obj(t_k)

 if targ_valid(t_k) then
  ls_t=true
  add_panel("cutting "..panel_proc(ls_p),1,10)
  to_x=t_x*8
  to_y=t_y*8
  
  dx=t_x<pl.x and -1 or 1

  if(abs(t_x-pl.x)+abs(t_y-pl.y)>2.5)find_targ()

  if brk_st(t_x,t_y,o) then
   mset(t_x,t_y,0)
   mk_act(o.drp,t_x-0.5,t_y-0.5)
   
   sfx(4)
   find_targ()

   for i=1,20 do
    mk_prt(flr(rnd(2))>0 and o.col or 7,10+rnd(11),to_x-1+rnd(3),to_y,-3+rnd(6),-1-rnd(3),0.6)
   end
  end
 else
  start_note("tool insufficient         ",2,10)
  find_targ()
 end
end

function show_obj_name()
 if(t_k!=nil) then
  add_panel(get_mat(get_obj(t_k).drp).ic..get_obj(t_k).name,0,get_obj(t_k).col)
 end
end

function draw_targ()
 spr(10+flr(time()*2%2),t_x*8-4,t_y*8-6,1,1)
 
 if(t_k!=nil) then
  add_panel("❎ use tool",1,6)
 end
end

function draw_laser()
 lsr_c=15
 if(u_rk>=2)lsr_c=9
 if(u_mt>=2)lsr_c=10
 lsr_c=flr(rnd(2))>0 and lsr_c or 7

 local wx=flr(rnd(2)-1)
 local wy=flr(rnd(2)-1)
 
 line(pl.x*8,pl.y*8-pl.off_y,to_x+wx,to_y+wy,lsr_c)
 
 lsr_dir=sgn(to_x-pl.x*8)
 mk_prt(lsr_c,2+rnd(11),to_x+wx,to_y+wy,(-0.25+u_ls*0.3+rnd(u_ls*0.3))*lsr_dir,-0.5-u_ls*0.3-rnd(u_ls*0.3),0.5)
end

function find_targ()
 local cls=100
 t_k=nil
 
 t_x=0
 t_y=0
 
 for i=-1,1 do
  for j=-1,1 do
   local x=flr(pl.x)+i+0.5
   local y=flr(pl.y)+j+0.5
   
   if fget(mget(x,y),0) then
    if(abs(x-pl.x)+abs(y-pl.y))>cls then
    else 
     cls=abs(x-pl.x)+abs(y-pl.y)
     t_x=x
     t_y=y
     t_k=mget(x,y)
    end
   end
  end
 end
end

function use_tool()
 if t_k!=nil then
  fire_laser()
 else
  find_targ()
 end
end

function find_cls_a(x,y)
 local cls=3
 local a_c=nil
 
 for a in all(act) do 
  local t_c=abs(x-a.x)+abs(y-a.y)
  if t_c<cls and fget(a.k,0) then
   cls=t_c
   a_c=a
  end
 end
 
 return a_c,cls
end

function control_pl(pl)
 if(abs(pl.dx)>abs(pl.dy)) then
  dx=pl.dx<0 and -1 or 1
  dy=0
 elseif(abs(pl.dx)<abs(pl.dy)) then
  dy=pl.dy<0 and -1 or 1
  dx=0
 end
 
 accel=0.030*pl_sp

 if not blk_x then
  if(btn(0))then
   pl.dx-=accel
   dx=-1
  end
  if(btn(1))then
   pl.dx+=accel
   dx=1
  end
 end
 if not blk_y then
  if(btn(2))then
   pl.dy-=accel
   dy=-1
  end
  if(btn(3))then
   pl.dy+=accel
   dy=1
  end
 end
 
 if btn(4) or btn(5) then
  use_tool()
 else
  ls_b=0
  find_targ()
 end
end

function pl_in_lab()
 return fget(mget(pl.x,pl.y),4)
end

function dmg_pl(dmg,sfx_n)
 if dmg_t<=0 then
  dmg_e_t=30

  p_c=in_ht and 8 or in_rd and 3
  p_c2=in_ht and 9 or in_rd and 11

  for i=1,10 do
   mk_prt(flr(rnd(2))>0 and p_c or p_c2,10+rnd(11),pl.x*8-1+flr(rnd(3)),pl.y*8-2-rnd(2),0,-rnd(5),0.6)
  end

  ox_t-=dmg
  dmg_t=12
  sfx(sfx_n)
 end
end

function refill_ox()
 if(ox_t<ox_m*0.95) then
  ox_t=(ox_p+0.1-ox_p*0.1)*ox_m
 else
  ox_t=ox_m
 end
end

function oxygen_hnd()
 local t=mget(pl.x,pl.y)
 
 if(not in_dth) then
  if t==36 or t==37 then
   in_ht=true
   if(u_ht<2)dmg_pl(3,18)
  elseif t==52 or t==53 then
   in_rd=true
   if(u_rd<2)dmg_pl(6,19)
  else
   in_ht=false
   in_rd=false
  end

  dmg_t-=1
 end

 if in_dth then
  pl_death()
 elseif ox_t<=-2 then
  pl_death()
 end

 if(pl_in_lab()) then
  refill_ox()
 elseif mget(pl.x,pl.y)==56 or mget(pl.x,pl.y)==57 then
  refill_ox()
 else
  ox_t-=1/30
 end

 ox_p=max(0,ox_t/ox_m)
 ox_c=s_col

 if(not in_dth) then
  if(ox_t<=5) then
   if flr(time()*4)%2==1 then
    ox_c=7
   else
    if(ox_c!=8)sfx(24)
    ox_c=8
   end
  elseif(ox_p<=0.334) then
   ox_c=8
  end
 end
 
 if dmg_e_t>0 then
  if(dmg_e_t%3!=0)ox_c=8
 end
end

function mk_obj(name,k,res,drp,col,up_lvl)
 o={
  name=name or "no_name",
  k=k,
  res=res or 50,
  drp=drp,
  col=col or 7,
  up_lvl=up_lvl or 1,
  need_rk=false,
  need_mt=false,
 }
 add(obj,o)
 return o
end

function setup_obj()
 mk_obj("fibrous plant",88,40,72,3)
 
 o=mk_obj("quartz deposit",89,80,73,15)
 o.need_rk=true

 mk_obj("miry fungus",80,40,64,13)
 mk_obj("miry fungus",96,40,64,13)
 mk_obj("big miry fungus",112,80,64,13)
 mk_obj("big miry fungus",113,80,64,13)

 mk_obj("tough fungus",82,80,66,14)
 mk_obj("tough fungus",98,80,66,14)
 mk_obj("big tough fungus",114,160,66,14)
 mk_obj("big tough fungus",115,160,66,14)

 mk_obj("sappy fungus",84,160,68,12)
 mk_obj("sappy fungus",100,160,68,12)
 mk_obj("big sappy fungus",116,320,68,12)
 mk_obj("big sappy fungus",117,320,68,12)

 mk_obj("bizzar fungus",122,420,74,11)

 o=mk_obj("rock",86,150,70,7)
 o.need_rk=true
 o=mk_obj("rock",102,150,70,7)
 o.need_rk=true
 o=mk_obj("boulder",118,300,70,7)
 o.need_rk=true

 o=mk_obj("scrap metal",87,300,71,9)
 o.need_mt=true
 o=mk_obj("scrap metal",103,300,71,9)
 o.need_mt=true
 o=mk_obj("metal structure",119,480,71,9)
 o.need_mt=true
end

function mk_mat(tag,k,name,ic,col)
 m={
  tag=tag,
  k=k,
  name=name or "no_name",
  amt=0,
  ic=ic or "■",
  col=col or 7,
  disc=false
 }
 return m
end

function setup_ma_tot()
 add(ma_tot,mk_mat("fungi1",64,"myxorid","○",13))
 add(ma_tot,mk_mat("fungi2",66,"uredia","⁘",14))
 add(ma_tot,mk_mat("fungi3",68,"oocete","⁙",12))
 add(ma_tot,mk_mat("rock1",70,"granite","■",7))
 add(ma_tot,mk_mat("metal1",71,"steel","■",9))
end

function setup_special_ma()
 ma_qrz=mk_mat("quartz1",73,"quartz","■",15)
 ma_plt=mk_mat("plant1",72,"fiber","~",3)
 ma_fn4=mk_mat("fungi4",74,"mytera","+",11)
end

function setup_mat()
 add(mat,mk_mat("fungi1",64,"myxorid","○",13))
 add(mat,mk_mat("fungi2",66,"uredia","⁘",14))
 add(mat,mk_mat("fungi3",68,"oocete","⁙",12))
 add(mat,mk_mat("rock1",70,"granite","■",7))
 add(mat,mk_mat("metal1",71,"steel","■",9))
 add(mat,mk_mat("plant1",72,"fiber","~",3))
 add(mat,mk_mat("quartz1",73,"quartz","■",15))
 add(mat,mk_mat("fungi4",74,"mytera","+",11))
end

function add_mat(tag,amt)
 for m in all(mat) do
  if m.tag==tag then
   m.amt=amt
   add(col_ma,m)
  end
 end
end

function find_mat(k)
 for m in all(mat) do
  if m.k==k then
   return m
  end
 end
 return nil
end

function start_note(s,l,c)
 if(not nt_on) then
  sfx(2)
  glitch_line(l,3)
  nt_s=s
  nt_l=l
  nt_c=c
  nt_on=true
 end
end

function show_note()
 if(nt_t<=60) then
  add_panel(nt_s,nt_l,nt_c)
  nt_t+=1
 else
  nt_t=0
  nt_on=false
 end
end

function collect_mat(tag,amt)
 for i=1,ma_sl do
  if col_ma[i]!=nil then
   if col_ma[i].tag==tag then
    if col_ma[i].amt<ma_m then
     col_ma[i].amt=min(ma_m,col_ma[i].amt+amt)
     return true
    else
     start_note("◀ case slot full",2,9)
     return false
    end
   end
  else
   add_mat(tag,amt)
   return true
  end
 end
 start_note("◀ no empty slots",2,9)
 return false
end

function rem_mat(ma)
 del(col_ma,ma)
end

function analyse_mat()
 for ma in all(col_ma) do
  if(ma.tag==ma_plt.tag) then
   dset(41,1)
   if(ma_plt.disc==false)found_new=true
   ma_plt.disc=true
  end
  
  if(ma.tag==ma_qrz.tag) then
   dset(42,1)
   if(ma_qrz.disc==false)found_new=true
   ma_qrz.disc=true
  end

  if(ma.tag==ma_fn4.tag) then
   dset(43,1)
   if(ma_fn4.disc==false)found_new=true
   ma_fn4.disc=true
  end

  for t in all(ma_tot) do
   if(ma.tag==t.tag) then
    if(t.disc==false)found_new=true
    t.amt+=ma.amt
   end
  end
  found_some=true
 end
 save_col_mat()
 foreach(col_ma,rem_mat)
end

function glitch_line(line,num)
 num=min(20,num)
 s=""
 
 for i=0,num do
  s=s..chr(15+rnd(64))
 end
 add_panel(s,line)
end

function at_s_term()
 if mget(pl.x,pl.y)==51 then
  if not in_sci then
   pl.dx=0
   pl.dy=0
   
   in_sci=true
   found_some=false
   found_new=false
   anl_t=0
   analyse_mat()
   sfx(10)
   glitch_line(0,5)
  end

  add_panel("sample analysis",0,7)
  if found_some then
   blk_x=true
   blk_y=true

   if anl_t<anl_d then
    add_panel("samples received",1,10)
    add_panel("processing "..panel_proc(anl_t/anl_d),2,10)
    if(flr(anl_t/anl_d*10)%2==0) then
     if(anl_blp) then
      sfx(27)
      anl_blp=false
     end
    else
     anl_blp=true
    end
    
    anl_t+=1/30
   else
    blk_x=false
    blk_y=false

    if found_new then
     add_panel("new samples found",1,11)
     add_panel("more upgrades added",2,11)
     if(anl_blp) then
      anl_blp=false
      sfx(28)
     end
     upd_msgs()
    else
     add_panel("no new discoveries",1,6)
     if(anl_blp) then
      anl_blp=false
      sfx(29)
     end
    end
    
   end
  else
   add_panel("insert samples to",1,6)
   add_panel("research upgrades",2,6)
  end
 else
  if in_sci then
   in_sci=false
   anl_blp=true
   sfx(11)
   glitch_line(0,5)
  end
 end
end

function upd_msgs()
 function chk_msg(msg,term)
  if dget(msg.data)>=1 then
   if(not msg.unlk) then
    if(term==1)new_cm=true
    if(term==2)new_sc=true
   end
   msg.unlk=true
  end
 end

 for msg in all(cm_msg) do
  chk_msg(msg,1)
 end
 for msg in all(sc_msg) do
  chk_msg(msg,2)
 end
end

function mk_msg(l0,l1,l2,l3,data,hcol)
 m={
  l0=l0 or "",
  l1=l1 or "",
  l2=l2 or "",
  l3=l3 or "",
  data=data or u_ox,
  hcol=hcol or 7,
  unlk=false,
 }
 return m
end

function setup_cm_msg()
 m=add(cm_msg,mk_msg("…out of time.","but you know that.","find that specimen.","good luck!"))
 m.unlk=true
 m.hcol=6

 m=add(cm_msg,mk_msg("…the key to a big","breakthrough in our","research.","we are running…  ⬇️"))
 m.unlk=true
 m.hcol=6

 m=add(cm_msg,mk_msg("hq:mission briefing","we have great hope","in this location.","it might hold…   ⬇️"))
 m.unlk=true
 m.hcol=12

 m=add(cm_msg,mk_msg("…has interesting","qualities to it.","please keep going.","",31,6))
 m=add(cm_msg,mk_msg("hq:data received 1","this one appeared","on our initial scans","it certainly…    ⬇️",31,12))

 m=add(cm_msg,mk_msg("…but it might help","you get further","in your exploration.","",32,6))
 m=add(cm_msg,mk_msg("hq:data received 2","we got your results.","it is not what we","are looking for… ⬇️",32,12))

 m=add(cm_msg,mk_msg("…elements we are","after. useful, but","not groundbreaking.","keep searching.",33,6))
 m=add(cm_msg,mk_msg("hq:data received 3","intriguing find!","it seems to contain","some of the…     ⬇️",33,12))

 m=add(cm_msg,mk_msg("…all of us. i wish","it were possible to","bring you back.","thank you. goodbye.",43,6))
 m=add(cm_msg,mk_msg("…further, but i am","certain it is what","we are after.","thank you from…  ⬇️",43,6))
 m=add(cm_msg,mk_msg("hq:data received 4","the results are","fascinating! we need","to analyze it…   ⬇️",43,12))
end

function setup_sc_msg()
 m=add(sc_msg,mk_msg("science terminal","shows results for","sample analysis"))
 m.unlk=true
 add(sc_msg,mk_msg("analysis: myxorid","researched:","case capacity","",31,13))
 add(sc_msg,mk_msg("analysis: uredia","researched:","blast velocity","enzyme injector",32,14))
 add(sc_msg,mk_msg("analysis: oocete","researched:","oxygen capacity","co2 resonator",33,12))
 add(sc_msg,mk_msg("analysis: granite","researched:","ceramic plating","",34,7))
 add(sc_msg,mk_msg("analysis: quartz","researched:","sample slots","",42,7))
 add(sc_msg,mk_msg("analysis: fiber","researched:","lightweight fabric","",41,11))
 add(sc_msg,mk_msg("analysis: steel","researched:","grade-z shielding","",35,9)) 
 add(sc_msg,mk_msg("analysis: mytera","researched:","inconclusive","contact headquarter",43,3)) 
end

function enter_msg_ui(msgs)
 if not in_msg then
  blk_y=true
  in_msg=true

  for i=#msgs,1,-1 do
   if(msgs[i].unlk)add(aval_mg,msgs[i])
  end

  cur_msg=1
  
  sfx(10)
  glitch_line(0,5)
  glitch_line(1,1)
  glitch_line(2,3)
  glitch_line(3,3)
 end
end

function exit_msg_ui()
 function rem_msg(msg)
  del(aval_mg,msg)
 end

 if in_msg then
  blk_y=false
  in_msg=false

  foreach(aval_mg,rem_msg)
  sfx(11)
  glitch_line(0,5)
 end
end

function at_m_term()
 if mget(pl.x,pl.y)==39 then
  new_cm=false
  enter_msg_ui(cm_msg)
  draw_msg_ui(cm_msg)
 elseif mget(pl.x,pl.y)==12 then
  new_sc=false
  enter_msg_ui(sc_msg)
  draw_msg_ui(sc_msg)
 else
  exit_msg_ui()
 end
end

function draw_msg_ui(msgs)
 if(btnp(3) or btnp(4) or btnp(5)) then
  glitch_line(0,5)
  glitch_line(1,1)
  glitch_line(2,3)
  glitch_line(3,3)

  cur_msg=min(cur_msg+1,#aval_mg)
  sfx(0)
 end

 if(btnp(2)) then
  glitch_line(0,5)
  glitch_line(1,1)
  glitch_line(2,3)
  glitch_line(3,3)

  cur_msg=max(cur_msg-1,1)
  sfx(1)
 end
 
 function draw_msg(msg)
  add_panel(msg.l0,0,msg.hcol)
  add_panel(msg.l1,1,6)
  add_panel(msg.l2,2,6)
  add_panel(msg.l3,3,6)
 end
 
 if(not(btnp(2) or btnp(3) or btnp(4) or btnp(5)))draw_msg(aval_mg[cur_msg])
end

function enter_up_ui()
 if not in_up then
  blk_x=true
  in_up=true
  
  inf_cur=inf_sp
  inf_sw=false
  inf_t=0

  sfx(10)
  glitch_line(0,5)
  glitch_line(1,1)
  glitch_line(2,3)
  glitch_line(3,3)
 end
end

function exit_up_ui()
 if in_up then
  blk_x=false
  in_up=false

  sfx(11)
  glitch_line(0,5)
 end
end

function at_u_term()
 if mget(pl.x,pl.y)==49 then
  enter_up_ui()
  draw_up_ui(s_up,"hazmat suit upgrades",s_col)
 elseif mget(pl.x,pl.y)==50 then
  enter_up_ui()
  draw_up_ui(c_up,"sample case upgrades",c_col)
 elseif mget(pl.x,pl.y)==48 then
  enter_up_ui()
  draw_up_ui(t_up,"blast tool upgrades",t_col)
 else
  exit_up_ui()
 end 

 if(not in_up)u_cx=0
end

function draw_up_ui(u_cat,name,col)
 add_panel(name,0,col)
  
 add_panel("   ",1,6)
 
 for i=1,#u_cat do
  s=u_cat[i].st

  if u_cat[i+1]!=nil then
   if u_cat[i+1].pre then
    a=u_cat[i].icon.."-"
    b="■-"
   else
    a=u_cat[i].icon.." "
    b="■ "
   end
  else
   a=u_cat[i].icon.." "
   b="■ "
  end

  if s==0 or u_cat[i].disc==false then
   add_panel(b,1,1)
  else
   if(s==1)add_panel(a,1,13)
   if(s==2)add_panel(a,1,u_cat[i].col)
  end
 end

 if(u_cx==nil)u_cx=0

 if btnp(1) then
  u_cx=(u_cx+1)%#u_cat
  sfx(0)

  inf_cur=inf_sp
  inf_sw=false
  inf_t=0
 end
 if btnp(0) then
  u_cx=(u_cx-1)%#u_cat
  sfx(1)

  inf_cur=inf_sp
  inf_sw=false
  inf_t=0
 end
 
 if flr(time()*4%2)==0 then
  tx=add_panel("◀ ▶",1,7)
  tx.app=false
  tx.x=4*(2+u_cx*2)
 end
 cur_up=u_cat[u_cx+1]

 tx=add_panel("❎",1,(cur_up.st==1 and cur_up.disc) and can_buy(cur_up) and 7 or 1)
 tx.app=false
 tx.x=0

 if inf_t<=0 then
  if inf_sw then
   info=(cur_up.st>0 and cur_up.disc) and cur_up.info or "analyze new samples"
   txt_col=6
   inf_sw=false
  else
   info=(cur_up.st>0 and cur_up.disc) and cur_up.name or "needs research"
   txt_col=7
   inf_sw=true
  end
  
  inf_cur=min(inf_cur+0.2,2)
  inf_t=inf_cur
 end
 
 inf_t-=1/30

 add_panel(info,2,txt_col)

 if(cur_up.st==1 and cur_up.disc) then
  for i=1,#ma_tot do
   if cur_up.cost[i]!=nil and cur_up.cost[i]>0 then
    add_panel(ma_tot[i].ic,3,ma_tot[i].col)
    add_panel(ma_tot[i].amt.."/"..cur_up.cost[i].." ",3,ma_tot[i].amt>=cur_up.cost[i] and 6 or 8)
   end
  end
 elseif cur_up.st==2 then
  add_panel("upgrade acquired",3,6)
 end

 if(btnp(4) or btnp(5)) then
  u=u_cat[u_cx+1]
  if(cur_up.st==1 and cur_up.disc) then
   apply_up(u_cat,u_cx+1)
  end
 end
end

function draw_ma_tot()
 for i=1,#ma_tot do
  add_panel(ma_tot[i].ic,3,ma_tot[i].col)
  add_panel(ma_tot[i].amt.." ",3,6)
 end
end

function pl_death()
 if(not in_dth) then
  for i=1,20 do
   mk_prt(flr(rnd(2))>0 and 13 or 7,10+rnd(11),pl.x*8-2+rnd(3.1),pl.y*8+4,0,-3-rnd(3),0.6)
  end
  sfx(22)
 end

 if(dth_t<dth_d*0.5) then
  dmg_t=0
  foreach(col_ma,rem_mat)
  in_dth=true
  dth_t+=1
  add_panel("◀ oxygen depleted",0,8)
 elseif(dth_t<dth_d) then
  dmg_e_t=0
  pl.dx=0
  pl.dy=0
  pl.x=pl_x+0.5
  pl.y=pl_y+0.5

  mk_prt(flr(rnd(2))>0 and 11 or 7,10+rnd(11),8+pl_x*8-6+rnd(4),8+pl_y*8,0,-2-rnd(2),0.6)
  sfx(23)
  add_panel("regenerating"..panel_proc((dth_t-dth_d*0.5)*2/dth_d),0,11)
  dth_t+=1
 else
  if(in_dth) then
   for i=1,20 do
    mk_prt(flr(rnd(2))>0 and 11 or 7,10+rnd(11),pl.x*8-2+rnd(3.1),pl.y*8+4,-1+rnd(2),0.5-rnd(6),0.6)
   end

   in_dth=false
   dth_t=0

   if(show_logo) then
    show_logo=false
    if(music_on)music(0)
   end
  end
 end
end

function reset_map()
 rem_all_act()
 reload(0x2000,0x2000,0x2000)
 spawn_act()
end

function map_hnd()
 if(pl_in_lab()) and (not was_lab) then
  reset_map()
  sfx(25)
  was_lab=true
 end
 
 if(not pl_in_lab()) and (was_lab) then
  was_lab=false
 end
end

function upd_menu()
 menuitem(2,(music_on and "▮ music on" or "0 music off"),
  function()
   music_on=not music_on
   if music_on then
    music(0)
    dset(0,0)
   else
    music(-1)
    dset(0,1)
   end
   menuitem(nil,(music_on and "▮ music on" or "0 music off"))
   return true
  end
 )
 menuitem(3,"▶ delete save",
  function()
   del_save()
  end
 )
end

function _update()
 room_x=flr(pl.x/16)
 room_y=flr(pl.y/12)
 
 cam_x=room_x*128
 cam_y=room_y*96

 upd_menu()

 ls_t=false
 scn_t=false

 if(not in_dth)control_pl(pl)
 
 oxygen_hnd()

 at_u_term()
 at_s_term()
 at_m_term()

 if not(in_msg or in_up) and pl_in_lab() then 
  draw_ma_tot()
 end

 map_hnd()
 
 foreach(act,move_act)
 foreach(prt,move_prt)
 foreach(prt,rem_prt)

 if(nt_on)show_note()
end

function rem_prt(p)
 if(p.t>p.life)del(prt,p)
end

function move_prt(p)
 p.x+=p.dx
 p.y+=p.dy
 p.dx*=p.drag
 p.dy*=p.drag
 p.t+=1
end

function draw_prt(p)
 pset(p.x,p.y,p.col)
end

function mk_prt(col,life,x,y,dx,dy,drag)
 p={
  col=col,
  life=life,
  x=x,
  y=y,
  dx=dx or 0,
  dy=dy or -1,
  drag=drag or 0.9,
  t=0,
 } 
 add(prt,p)
 return p
end

function draw_act(a)
 local sx=(a.x*8)-4
 local sy=(a.y*8)-4-(a.off_y!=nil and a.off_y or 0)
 
 if a.k==32 then
  pal(11,ox_c)
  
  if(u_ht<2) then
   pal(4,6)
   pal(1,5)
  end

  if(u_rd<2)then
   pal(9,6)
   pal(10,7)
  end
  
  if dmg_e_t>0 then
   if dmg_e_t%3!=0 then
    pal(9,8)
    pal(4,8)
   end
   dmg_e_t-=1
  end

  spr(a.k+a.frm,sx,sy,1,1,(dx<0)or false,false)
  
  pal()
 else
  sy=sy+sin(0.75*time()+(sx+sy)*0.1)*1.1
  spr(a.k+a.frm,sx,sy,1,1,a.dx<0)
 end
end

function panel_proc(proc)
 return
  proc<=0.2 and "|▮    |" or
  proc<=0.4 and "|▮▮   |" or
  proc<=0.6 and "|▮▮▮  |" or
  proc<=0.8 and "|▮▮▮▮ |" or
  "|▮▮▮▮▮|"  
end

function add_panel(s,l,col)
 tx={
  s=s or " ",
  l=l or 0,
  x=0,
  y=0,
  col=col or 7,
  app=true
 }
 add(txts,tx)
 return tx
end

function draw_to_panel(tx)
 if(txt_x==nil)txt_x=0

 if tx.app then
  txt_x=print(tx.s, 
   tx.x+((txt_x<=0) and (cam_x+40) or txt_x), 
   tx.y+tx.l*6+cam_y+100, 
   tx.col)
 else
  print(tx.s, 
   tx.x+cam_x+40, 
   tx.y+tx.l*6+cam_y+100, 
   tx.col)
 end
end

function rem_txt(tx)
 del(txts,tx)
end

function draw_ui(x,y)
 rectfill(x,y,x+127,y+31,0)
         
 x-=2
 y+=1
 print(max(ceil(ox_t),0),x+6,y+3,ox_c)
 
 for i=0,4 do
  line(x+23+6+2*i,y+3,x+23+6+2*i,y+7,1)
 end

 rectfill(x+7+2*4,y+3,x+5+5*4+u_ox*2,y+7,ox_c==s_col and 3 or 1)
 rectfill(x+7+2*4,y+3,x+8+2*4+ox_p*(10+u_ox*2),y+7,0)
 rectfill(x+7+2*4,y+3,x+7+2*4+ox_p*(10+u_ox*2),y+7,ox_c)
 
 for i=0,4 do
  line(x+22+6+2*i,y+3,x+22+6+2*i,y+7,0)
 end
 
 for i=1,3 do
  line(x+7+(11*(i-1)),y+16,x+14+(11*(i-1)),y+16,1)
 end
 
 for i=1,ma_sl do
  rectfill(x+6+(11*(i-1)),y+9,x+6+9+(11*(i-1)),y+9+10,0)
  rect(x+6+(11*(i-1)),y+9,x+6+9+(11*(i-1)),y+9+10,9)
  print(ma_m,x+8+11*(i-1),y+14,1)
  
  if col_ma[i]!=nil then
   rectfill(x+6+(11*(i-1)),y+9,x+6+9+(11*(i-1)),y+9+10,1)
   rectfill(x+6+(11*(i-1)),y+9,x+6+(11*(i-1)),y+9+10,4)
   
   local ma_proc=col_ma[i].amt/ma_m
   print(col_ma[i].ic,x+10+11*(i-1),y+9,col_ma[i].col)
   print(col_ma[i].amt,x+8+11*(i-1),y+14,7)
   rectfill(x+6+(11*(i-1)),y+18-flr(10*ma_proc),x+6+(11*(i-1)),y+9+10,0)
   rectfill(x+6+(11*(i-1)),y+19-flr(10*ma_proc),x+6+(11*(i-1)),y+9+10,9)
  end
 end

 for i=0,4 do
  line(x+6+2*i,y+21,x+7+2*i,y+25,i+2<=u_ls and 10 or 1)
 end
 print("c",x+6+13,y+21,u_ht>1 and s_col or 1)
 print(" l",x+6+13,y+21,u_sp>1 and s_col or 1)
 print("  z",x+6+13,y+21,u_rd>1 and s_col or 1)
 print("   e",x+6+13,y+21,u_rk>1 and t_col or 1)
 print("    r",x+6+13,y+21,u_mt>1 and t_col or 1)
 
 if #aval_mg>=2 then
  for i=0,#aval_mg-1 do
   if(i+1==cur_msg) then
    c=flr(time()*4%2)==0 and 7 or 0
    line(x+124,y+3+i*2,x+126,y+3+i*2,c)
    
   else
    line(x+124,y+3+i*2,x+126,y+3+i*2,6)
   end
  end
 end

 for i=0,3 do
  for tx in all(txts) do
   if tx.l==i then
    draw_to_panel(tx)
   end
  end
  txt_x=0
 end
 foreach(txts,rem_txt)

 l=flr(time()*-9)%(28+40)
 
 if l!=lst_l then
  off=rnd(3)
 end
 
 for h=0,2+2-off do
  local px={}
  for i=0,127 do
   add(px,pget(x+i,y+l+h))
  end

  for i=0,127 do
   pset(x+i+off,y+l+h,px[i+1])
  end
 end
 
 local nz=2
 if ox_p<=0.167 then
  nz=400
 elseif ox_p<=0.334 then
  nz=100
 end
 for i=1,nz do
  pset(x+1+rnd(128),y+1+rnd(27),rnd(2))
 end
 
 lst_l=l
 
 if(show_logo) then
  rectfill(x,y,x+127,y+100,0)
  spr(128,x+1,y-24,16,4)
 end
end

function _draw()
 cls()

 if(pl_in_lab())clip(3*8,2*8,10*8,7*8)
 
 camera(cam_x,cam_y)
 
 map()
 
 if new_cm then
  if(flr(time()*2)%2==0)line(20*8+6,19*8+2,20*8+6,19*8+4,7)
 end

 if new_sc then
  if(flr(time()*2)%2==0)line(24*8+1,19*8+2,24*8+1,19*8+4,7)
 end

 if not pl_in_lab() then
  rectfill(19*8+3,14*8,28*8+4,(15+5)*8-1,0)
  rectfill(19*8+4,14*8-1,28*8+3,(15+5)*8-2,6)
 end
 
 for a in all(act) do
  if(a.k!=32)draw_act(a)
 end

 foreach(prt,draw_prt)

 if(not in_dth) then
  ovalfill(pl.x*8-2,pl.y*8-1,pl.x*8+1,pl.y*8+1,0)
  draw_act(pl)
 else
  if(pl_in_lab())rect(pl_x*8+2,pl_y*8+2,pl_x*8+5,pl_y*8+5,11)
 end

 if not in_dth then
  if(ls_t)draw_laser()
  
  show_obj_name()
  if(not ls_t)draw_targ()
 end

 if(pl_in_lab())clip(0,0,128,128)

 draw_ui(cam_x,cam_y+96)
end
__gfx__
00000000000000000000000300000000000000000000000300000000066666600666666006666660007777000000000000000000000000000000000000000004
07000070000000030000003300000000000000000000003305555550666666660066660066666666000770000077770005555550000000000000000000000044
00700700000000030000003300000000000000000000003305555550666666665066660560000006000000000007700005555750000000000000000000000044
00077000000000030000003300000000000000000000503305555550000001005066660550555505000000000000000005555750000000000000000000000044
00077000000000000000000300000000000005500055000305555550000010005066660550555505000000000000000005555750000000000000000000000044
00700700000000050000005000000000050000000000005005555550000100005066660550555505000000000000000005555750000000000000000000000004
07000070000000050000005500333300000000000033305505555550001000005066660550555505000000000000000005555550044440000000000000444020
00000000000000000000000533333330003333303333330500000000555555550066660000555500000000000000000000000000444444400044444004444402
03333300033330000003333000000000050050500000000066666660000000000666666006666660000000000044444000044440000000000000000000000000
33333330333333300333333300000000005000000000000000000006050505006666666666666666044440000444444444444444000022000220002000000000
33333330333333330333333300000500000000000000000005050500030505006666666660000006444444404444444444444444020000000002200000000000
03333330333333335033330505000000000000000000000005050505050305050000030050555505444444404444444404444440000000000000000000000000
50033305333333335000005000000000000000000000000005050305050303030000303050535505044444004444444420000002000220000000000000000000
55500055333333330555555000005000000000000500000005050503050503050303003350553505200000204444440022222222000000000000000000000220
05555550033333330055555500000000000000000000050005050503050505050333033050533505222222200444402202222220022000200000000002220000
00555505000333305555500000000000000000000000000000000005000000055335553300333500022222020000022020000000000000000000000000000000
00000000000000000000000000000000200022200222000006666660000000000000000000000000000000000060660006666660000000000000000000000002
000000000009a000000000000009a0000222282228822200666666660555555005555550055555500505050066d6dd6666666666000000000000000000000022
0009a00000b9a0000009a00000b9a00000002200222282226066660605c5555005dddd5005555550050505006666666660000006000000000000000000000022
00b9a0000014900000b9a00000d4100002200002020022825066660505c5555005d55d500757575007070705d555555d50575505000000000000000000000022
00d4900000d4400000d4900000d4400022222222282002225066660505c5555005d55d500757575007070705d566665d50515505000000000000000000000002
00d140000004400000d140000004400028828220228200005066660505c5555005dddd500555555005050507d6dddd6d505c5505000000000000000000000010
00044000000040000004400000040000222822200022220050666605055555500555555005555550050505076666666650515505002222000000000000222011
0004400000000000000440000000000002222000000002200066660000000000000000000000000000000005d000000d005c5500222222200022222022222201
06ddda6006dddb6006ddd96000000000010000100000000006660000066666600006000000616000022222000222220000022220000000000001000100000000
0000000000000000000000000555555000000001001111000666666666666666665d555005666566220022202222222002222002000100000100010000000000
0555555005555550055555500557555001110010013331100666dddd600000066166665006ddd616222222202202202202002022000001000000000000000000
055aa550055bb550055995500577575000131110131111310666000d066666606166665006666616020220022022200222002222010000000000000000000000
0555555005555550055555500577575000133110110001110666000d061111606166665006666616222220022200222222220220000000000000000000000000
05aaaa5005bbbb50059999500557555000013100010000010ddd66660d1111d066dddd500ddddd66222022222200222002001001000010000000000000000000
0555555005555550055555500555555001101101000000100dd6dddd0d1111d0dddddd500ddddddd000102202222200110111111010000100000000000100001
000000000000000000000000000000000010001000011100000d0000066666600000000000000000011111010222201101111110000000000000000010000100
00000000d000000d00000000e000000e00000000c000000c00000000000000000000000000000000000000000000000000000000000000005555555555550000
00000000dd0000dd00000000ee0000ee00000000cc0000cc0000000000000000000000000000000000000000000000000000000050555555cccccccccccc5500
000700000dd00dd0007070000ee00ee0007070000cc00cc000666000007470000000b0000077f000000b0000000000000000000005ccccccc6cc666c666c0c50
00d0d00000dddd00000e000000eeee000007000000cccc0000665000009490000033300000f7700000b7b00000000000000000005ccc66cccccccccccccc5cc0
000d0000000ddd0000e0e000000eee0000c0c000000ccc0000556000009490000030000000ff7000000b00000000000000000000cc6ccccccccccccccccc6c00
000000000ddd0dd0000000000eee0ee0000000000ccc0cc000000000000000000000000000000000000000000000000000000000ccccccccccccccccccc6ccc0
00000000ddd000dd00000000eee000ee00000000ccc000cc000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccc0
00000000d000000d00000000e000000e00000000c000000c000000000000000000000000000000000000000000000000000000000000cccccccccccc0ccc000c
00000000d000000d00000000e000000e00000000c000000c0000000000000000000b000000000700000000000000000000000000000000000000000000000000
00ddd000dd0000dd0000e000ee0000ee00000c00cc0000cc00000000000000000b0300000000ff00000000000000000000000000000000000000000000000000
0ddddd000dd00dd0000ee0000ee00ee000c001000cc00cc00066660000000000030b30000007f770000000000000000000000000000000000000000000000000
0005000000dddd0000002e0000eeee000011010000cccc0000666600009900003b0300b000ff7f70000000000000000000000000000000000000000000000000
00055005000ddd0000e22ee0000eee0000011100000ccc000656660000049900030b003007f7ff75000000000000000000000000000000000000000000000000
005055000ddd0dd00ee222000eee0ee00c0110000ccc0cc006655500040044900b0303b0577fff75000000000000000000000000000000000000000000000000
50000000ddd000dd00222202eee000ee00111010ccc000cc0000000000000000030b003057ffff50000000000000000000000000000000000000000000000000
00000500d000000d00000000e000000e00000000c000000c00000000000000000003000005555500000000000000000000000000000000000000000000000000
00000000d000000d00000000e000000e00000000c000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd0000dd00e00000ee0000ee00000000cc0000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dd000dd00dd00ee00e000ee00ee0000c00000cc00cc000066600000090000000000000000000000000000000000000000000000000000000000000000000
000dddd000dddd0000202ee000eeee000001000000cccc0000666600000940000000000000000000000000000000000000000000000000000000000000000000
00005500000ddd00002e2200000eee00c01100c0000ccc0000666600009940000000000000000000000000000000000000000000000000000000000000000000
500555000ddd0dd000ee22000eee0ee00111c0100ccc0cc000555560009440400000000000000000000000000000000000000000000000000000000000000000
00555050ddd000dd20222020eee000ee00111110ccc000cc00000650000000000000000000000000000000000000000000000000000000000000000000000000
00000000d000000d00000000e000000e00000000c000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000dddd000000000000e0000000000c00000000000666600000099000000000000000000007b007bb0000000000000000000000000000000000000000
0ddddd000dddddd000ee00000ee000000000010000000c00666666000994490000000000000000007bb0b77b0000000000000000000000000000000000000000
ddddddd00dddddd000ee0e000020ee000cc00100cc00100066666600049449000000000000000000b330b7bb0000000000000000000000000000000000000000
ddddddd00dddddd0eeee0ee00022ee000cc10cc0cc0c1cc0666665600449449000000000000000000330bbb00000000000000000000000000000000000000000
ddddddd000055000eeee02000e22eeee01110cc001111cc05666656604494449000000000000000007b113300000000000000000000000000000000000000000
0055500000055ddd00222200ee22eeee00cc11000011c110555556660444944900000000000000001bb303310000000000000000000000000000000000000000
0055dd000dd55500022222000220222001cc11100111110055555660004494400000000000000000300030030000000000000000000000000000000000000000
05055550050555502222202000000000011111110000000005550560000000000000000000000000011311100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000ddd000000000000000dddd000000000000000000000000000000000000000000000000000ddd00000000000000000000000000000
000000000000000000000000100000000000000000110000000000000000000dddd0000000000000000000000000000ddddd0000000000000000000000000000
00000000000000000000000011100000000000000111000000000000000000001100000000000000000000000000000001000000000000000000000000000000
00000000000000000000000001666666006666666611666006660006666666611006660006660006666600000666661111006666000000000000000000000000
00000000000000000000000006666666606666666661666006660066666666661006660006660066665500006666666110066666600000000000000000000000
00000000000000000000000006665556606665556660666006660066665566666006660006660666650000006665566610666556600000000000000000000000
00000000000000000000000006660005506660006660666006660666650056666606666006660666500ddd066650056610666005500000000000000000000000
00000000000000000000000006660000006660066660666666660666600005666606666006660666000010066600006660666600000000000000000000000000
000000000000000000000000056666660066666666506666666606666000006666066666066606660dd010066600006660666660000000000000000000000000
00000000000000000000000000666666606666665500666556660666600000666606666606660666001111066600006660566666000000000000000000000000
00000000000000000000000000555666606665550000666006660666600000666606655666660666000661066600006660056666600000000000000000000000
00000000000000000000000000000666606650000000666006660666600000666606500666660666000660056600006660005666600000000000000000000000
00000000000000000000000000006665506d00000000665005660566660000666506000556660666600566006600006650000666500000000000000000000000
00000000000000000000000000066d50006d000000006d000066005666000666d006000005660566666666005660066600066655000000000000000000000000
0000000000000000000000000065d00006d000000006500000d60005d660666d000d0000005d6055555d6660056606d5066d5500000000000000000000000000
00000000000000000000000000d000000d000000000d0000000d00000d6666d0000d00000000d000000055dd00550d00dd500000000000000000000000000000
00000000000000000000000010d000000d00000000d00000000d00000dd555d0000d00000000d00000000000d0000d0d00000000000000000000000000000000
00000000000000000000000001d100000d000000d0d00000000d0000d00000d0000d010000000d10000000000d000d0d00000000000000000000000000000000
0000000000000000000000000d0010000d00000000d10000000d000d00000d000000d01100000d01000000000d000d00d0110110000000000000000000000000
000000000000000000000000d000110000d0000000d001000dd0000d00000d0000000d0010000d00000000000d000d000d000001000000000000000000000000
000000000000000000d00dd00d000100000d00000d0d0000d00d1100000001d000000d0010000d000d0000000d0000d000dd0000100000000000000000000000
00000000000000000000000000d000d0000d0000d00d00100000d010000101d00000d00010000d0000d00000d0d00000d000d000000000000000000000000000
000000000000000000000000000d0000000d000d0d0000100000d000010000d000000d0000000d00100dd0d0010d00010d000000000000000000000000000000
00000000000000000000000000d01000dd01000d0d000010000d0000110000dd00000d000000d00010000d001010d0010d0000d0000000000000000000000000
0000000000000000000000000d00000d0000100000d000000000000001000000d0000000000d0000100000010001d00100d00000000000000000000000000000
000000000000000000000000000000000000100d0000010000d000000100d000d0dd000000d00d000100d00100000d0100d00000d00000000000000000000000
00000000000000000000000d0000000d0000100000d000000000000010000000d00000000d0000d00100d0010000d00010000000d00000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000d000d000000000d0000d000100000000000d0000000000000000000000000000
00000000000000000000000000000d0000010000000000000000010000000000000000000d000000000000010000000000000000000000000000000000000000
__label__
05000000000000000000033003300300030300000303300003303000033030000333000003333300000333300000333000003030000000000000000000005000
00000000000000000033330030333000330003303333300033330330033303000333033003333330033333330033033300003333000000000000000000000000
00000000000000000003333300303330333000033330333333330303333303303333333330303330033330300333300303330033000005000000000000000000
00000000000000005030030003330330030333033333033003303333033333300333333303330330503330055033330500330005000000000000000000000000
00000000000000005000005000003005330030033333333333003333500333053333330350033305500000505000000050000050000000000000000000000000
00000000000000000000555005500005333033330333333333333303555000553333033355500055055505500555555005505050000050000000000000000000
00000000000000000055055500555550033333300033333303333303055555500333333305555550005550550055555500505055000000000000000000000000
00000000000000005050500000505505000033000003300000030330005555000003333000555505555550000555500050505000000000000000000000000000
00000000000000000000000003333300033330000030330000033330033333000333330000033330000000000500505000000000000000000000000000000000
00000000000000000000000000033300333330003333333003333033333333303333330003333330000000000050000000000000000000000000000000000000
00000000000000000000000033303330333330300333333003033333333333303333333003333333000005000000000000000000000000000000000000000000
00000000000000000000000003330330030330300330333050333305033333300333333050333305050000000000000000000000000000000000000000000000
00000000000000000000000050033305500333055003330550000050500333055003330550000050000000000000000000000000000000000000000000000000
00000000000000000000000005000055055000555050005505555550555000555500005505555050000050000000000000000000000000000000000000000000
00000000000000000000000005550000055555500555555000555555055555500555555000555555000000000000000000000000000000000000000000000000
00000000000000000000000000555505000555050050550555555000005555050055550555555000000000000000000000000000000000000000000000000000
00000000000000000000000000000000050050500500505000000000050000500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000005000000050000000000000005000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000dddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000ddd000000000000000dddd000000000000000000000000000000000000000000000000000ddd000000000000000000000000000000
00000000000000000000000100000000000000000110000000000000000000dddd0000000000000000000000000000ddddd00000000000000000000000000000
00000000000000000000000111000000000000001110000000000000000000011000000000000000000000000000000010000000000000000000000000000000
00000000000000000000000016666660066666666116660066600066666666110066600066600066666000006666611110066660000000000000000000030030
00000000000000000000000066666666066666666616660066600666666666610066600066600666655000066666661100666666000000000000000000003033
00000000000000000000000066655566066655566606660066600666655666660066600066606666500000066655666106665566000000000000000003330003
0000000000000000000000006660005506660006660666006660666650056666606666006660666500ddd0666500566106660055000000000000000000303305
00000000000000000000000066600000066600666606666666606666000056666066660066606660000100666000066606666000000000000000000050000000
00000000000000000000000056666660066666666506666666606666000006666066666066606660dd0100666000066606666600000000000000000005555550
00000000000000000000000006666666066666655006665566606666000006666066666066606660011110666000066605666660000000000000000000055550
00000000000000000000000005556666066655500006660066606666000006666066556666606660006610666000066600566666000000000000000050555000
00033300000000000000000000006666066500000006660066606666000006666065006666606660006600566000066600056666000000000003033000303000
0303300000000000000000000006665506d000000006650056605666600006665060005566606666005660066000066500006665000000000333333330303300
0003303000000000000000000066d50006d000000006d000066005666000666d0060000056605666666660056600666000666550000000000033033333333300
030030300000000000000000065d00006d000000006500000d60005d660666d000d0000005d6055555d6660056606d5066d55000000000005030030503303300
0000330500000000000000000d000000d000000000d0000000d00000d6666d0000d00000000d000000055dd00550d00dd5000000000000005000005050030305
5050000500000000000000010d000000d00000000d00000000d00000dd555d0000d00000000d00000000000d0000d0d000000000000000000555550050500050
0005555000000000000000001d100000d000000d0d00000000d0000d00000d0000d010000000d10000000000d000d0d000000000000000000050005500550050
000050050000000000000000d0010000d00000000d10000000d000d00000d000000d01100000d01000000000d000d00d01101100000000005505500000555500
03030300000000000000000d000110000d0000000d001000dd0000d00000d0000000d0010000d00000000000d000d000d0000010000000000330330003333300
0033303000ddd0000d00dd00d000100000d00000d0d0000d00d1100000001d000000d0010000d000d0000000d0000d000dd00001000000003303333033303330
333330000d0ddd00000000000d000d0000d0000d00d00100000d010000101d00000d00010000d0000d00000d0d00000d000d0000000000003333033003033030
00033000000500000000000000d0000000d000d0d0000100000d000010000d000000d0000000d00100dd0d0010d00010d0000000050000000300333003300030
5003330500000005000000000d01000dd01000d0d000010000d0000110000dd00000d000000d00010000d001010d0010d0000d00000000005003330500003005
055000000050500000000000d00000d0000100000d000000000000001000000d0000000000d0000100000010001d00100d000000000050000050005500000000
05505500500000000000000000000000000100d0000010000d000000100d000d0dd000000d00d000100d00100000d0100d00000d000000000550050005050550
0055550000000000000000d0000000d0000100000d000000000000010000000d00000000d0000d00100d0010000d00010000000d000000000055500000000500
030000000303330000000000000000000000000000000000000000000000000d000d000000000d0000d000100000000000d00000000333300003033000033330
3003033033333000000000000000d00000100000000000000000100000ddd00000000000d00000000ddddd100000000000000000033333330333303000000000
0333333033030330000000000000000000000000000000000000dd000ddddd000000000000000000ddddddd00000000000000000033333330333333003303333
003000000000330000000000000000000000000000000000000dddd0000500000000000000000000ddddddd00000000000000000503303055033330500033000
50033300500300050000000000000000000000000000000000005500000550050000000000000000ddddddd00000000000000000000000505000005050000000
55000050555000550500000000000000000000000000000050055500005055000000000000000000005550000000000005000000055555500500555000055550
055055000505555000000500000000000000000000000000005550505000000000000000000000000055dd000000000000000500005555500005505500555055
00005005005505050000000000000000000000000000000000000000000005000000000000000000050555500000000000000000555550005555000005050000
00440000000000000044444000044440000444400004444000444440000000000044444000044440000000000004444000444440000000000000444000004000
04044440044440000444044404444444404444444444444404444444044440000444444444444444040440004444444404444444044440004444444004040044
00444044044404404444444440044444444444444444444444444444444444404444444444444444444444404444444444444444404440404440400404440004
40004044444444404444444444404444044444400444444044444444444444404444444404444440444444400440444044444444444444000044404044444400
00040444044444004404444404444444200000022000000244444444044444004444444420000002044444002000000244444444044444002000000240040440
04404400000000204444440000444000222222222222222244444400200000204444440022222222200000202222222244404400200000202222202244040000
00444022022020200044402204444022022222200222222004444022222222200444402202222220222222200222222004444022222222200220222004400002
00000220022222020000022000000220200000002000000000000220022222020000022020000000022222022000000000000200022222002000000000000200
00440000000444000044440000000000000000000000000000444440000000000222000020002220000000000000000000000000004044402000000000400000
040000400004440000440444044440000000e00000ee00000444444404444000288222000222282200e0000000e0000004444000004444440200082000004404
40004404004400044444444444444440000ee00000ee0e00444444444444444022228222000022000ee00e000ee00e0044444440444444400000220040404400
0440404400044000444004444444044000002e00eeee0ee04444444444444440020022820220000200202ee000202ee044440440404444440220000244004400
0400004400000002044004400444000000e22ee0eeee020044444444044444002820022222222222002e2200002e220004444400444444002000200204044000
440044000022222044440000200000200ee22200002222004444440020000020228200002882822000ee220000ee220020000020404444002880002000404400
04000002022202200044402222202020002222020222220004444022222222200022220022282220202220202022202022222220044440022008220000440000
00000200200000000000022000222200000000002222202000000220022222020000022002222000000000000000000002222202000002200222000000000220
00404000004404400000000000444440000000002000202000000000000000002000222000000000000000000000000000000000004444400000202000000000
0000004004444444044400000444444400e00000022208220000e00000e00000022228220000e000000000000000000004444000040004440202002000404000
040444000404400444444440044444040ee00e0000002200000ee0000ee00e0000002200000ee000000000000000000044044440444444040000020044400000
4000404040444444444404404444440400202ee00220000200002e0000202ee00220000200002e00000000000000000044444440444444000020000000044400
40040004404000400404440044444444002022002222222200e22ee0002e22002200222200e22ee0000000000000000004444400044444000222020004400000
0040040000040000000000004444040000ee0200288282200ee2220000ee2200288282200ee22200000000000000000000000020444440000880802000000000
00400022004400202222222004404022202220202228222000222202202220202228222000222002000000000000000002020220044440220200020020020020
00000200000000000222200200000020000000000222200000000000000000000222200000000000000000000000000002220200000000200222200000000002
004004400000000000000000000444402000222002220000004444400044444000e0000000000000000000000000000000760000200022000202000000000000
00404404000040000440400044404444002228202802220004404444044444440ee000000000000000e00000000000000076b000002028200880020002020022
00004000000040004000440044404444000022000220020244444444444444440020ee00000000000ee00e00000000000066d000000002000002800000000000
00000400400440400444404004044000020000020200220244444444444444440020e0000000000000202ee0000000000065d000022000000200000000000000
00000000044400000044440020000002222220220820022244444444444444440e22eeee00000000002e22000000000000660000202222202000020002200000
0404000020000000200000202022222228820220208200004404440044444400ee22eeee0000000000ee22000000000000660000288200002000000020000000
00044022220200200022202002020220222802200022220000444022044440020220222000000000202220200000000000000000200002200020000002202220
00000020000202000220200020000000020220000000022000000220000002200000000000000000000000000000000000000000002020000000020000000000
00000000000000000000000000000000020200002000222000000000000000000000000000000000010000100000000000000000000000000000202002020000
0400400000200020000022000000000028822200022220020000e000000000000000000000000000000000010000000000000000000022000000002200800200
004000000002000000000000000000000020820000002000000ee000000000000000000000000000010100100000000000000000000000000000220000000020
40400000000000000000000000000000020002020220000000002e00000000000000000000000000001311100000000000000000000000000220000002000200
04000400000000000000000000000000282002022222200200e02ee0000000000000000000000000000331000000000000000000000000000022000028000000
0000002000000000000000000000000020000000088282200ee22000000000000000000000000000000131000000000000000220000000000800000002000000
00020000000000000000000000000000000222002200020000202202000000000000000000000000001011000000000000220000000000000000000000200000
00000000000000000000000000000000000000000220000000000000000000000000000000000000001000100000000000000000000000000000200000000000
00000000000220000002020000222000000020000222200000022220022202000002202000000000010000100000000000000000000022000002000002002000
00220220200200002020022020222200020000222222222002222000220022200022000000010000000000000011000000000000000002000020202020000000
00000000000200002200200000002020000022002202202002002022222200000200202200000100000100100103001000000000000020200200200022020000
00202000000020002020200000200000022000020000000022002222000220002200020200000000001301000311010000000000020000002000000000022002
22000200200000020200200202000222002200022000222222220020222200022020022000000000001300100100011000000000222020002000000202000000
20000000000000000200200000000200008282202000222000000001200020220200000100000000000030000000000000000000002000000000000000000000
00000000220000012000000020000000202800000200000010011101000002000001110000000000011011000000000000000000000100000200000000022000
00200000002000010020000002220010002000000000201001010010011110010110110000000000000000100001100000000000000111010020000100000011
00000200000000000000200000000000000000000001000000010000000100000000000000000000000000000000000000000000000000000202000000020000
00200000000000000000202000000000000000000100010001000100000001000000000000000000000000000000000000000001000000000000000000000000
20002020000000000000002000000100000000000000000000000000000000000000000000000000000000000011000001100010000000000002000002000000
20200000000000002020000000000000000000000000000000000000000000000000000000000000000000000010110000000100000000000002000000000000
00000000000300000000220000000000000000000000000000000000000000000000000000000000000000000000010000100000000000002220000000000000
02002020000030000200200000000000000000000000000000000000000000000000000000000000000000000001010000013000010100000200020002000000
00000000000001000000200000000010000000000000000000000000000000000000000000000000000000000000000000001000000100100000000010001100
00002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100010000000000000000000100100
00000000000020200200020000002000000000000000000000000000000000000000001000000000000000000000000000000000000000000020200002022000
00010000000000000200020000000000000000000000000000000000000000000000000000111100000000000010000000010100000220000000002000000020
00000100020020202000000200000002000000000000000000000000000000000011001000000010000000000000301000300100000020000200000000022020
00000000200020220000000000000002000000000000000000000000000000000000011010001000000000000001000000000030000000000000200000220000
11000000000000000200002200000200000000000000000000000000000000000003310010000010000000001000011010000000000000000000000000000022
00000000000000000000222000000000000000000000000000000000000000000001000001000000000000000000000101000000000000000200000022000020
00000010000000000220000000000000000000000000000000000000000000000010110000000010000000000000000000000000001001000000000000200001
00000000000000000000000100011000000000000000000000000000000000000000001000001000000000000000010000000000000000000020001000000000
00002000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000020000
00002000000000000000000000000000000000000011000000000000000000002000200000000000000000000000000000000000000000000000000000002000
200000000000000000000000000000000000000000300000000000000000000000022000000c00000000000000000000000000000000000000c0000000000000
20200000000100000000000000000000000000000000003101000000000000000000000000000000000000000000000000000000000000000000000002000000
00000020000000000000000000000000000000000000000000000000000000002020000000000000000000c00000000000000000000000000000000000000000
000002200000c0000000000100000000000000000100000000000000000000000200220000100010010000100001000000000000000000000000000000000000
00000000000100000000000100000000000000000000000001000000000000000000020000000010001000000000001000000000000000000001000000000000
00000001000000000000000000000000100001000000010000000000000000000100000000000000000000000000000000000000000000000000000000010000

__gff__
0000000000001002020200001000000002020200000010100202020202000000080808080000021010101002020000001010101000000202020202020200000004040404040404040004040000020202010101010101010103030000000000000101010101010101000000000000000003030303030303030000030000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
111011111110121012101211111010111111111110101211101111111111121111121111101012101210111110121011101011111211101011111211101011101a1b24251d1c1a1f1b1c1b1b1b1c1c1b1b1a1b1b1c1c1b1a1b1c1a1c1b1a1c1b1b1b1a1a1a1c1c1c1b0000001f1a1c1b3b3b3b3b3c3b3c3a3c3d0000003a3b3b
111111101070506071135010101112121111101012121012111112121012121112101210705000135010101012101010111010121010101010121012101111101a1b2525241b1c1d52627262521a1c1c1b1c1b1a52721b1a526262621a1b241b1b2400000000521b1c0000001d1b1b1b3b343b3d003e3e3e0000000000643a3c
121210605010507050506050501012111011111011101111101010121111111110105060501300000013601310127614140015140000101111101012121212101c1b25242525521e5262621b731a1c1b1b1b1a1b62005262525200001a1b241a1b25251d0000001e1e0000001e1b1c1c353c3b3c0000000034350000003c3b3b
105050601350506050101300601350101212121011111010111011111010101010605013121000001500000000100011111111121100001010130014501011111b1c1d25241b1b001f005262621c1c1c1b1a1a1c00001b1b7300620000242524252424001d1f0000001f001f241b1a1b3b643c003f353d003a646454003e543a
106070716060605010500050000000001413121011111110111012121213001400000000000000001110000000000010121110101012000000000000006010111b1a52001e1c252425251d00521c1b1b1a1e1d001f005200000000001f1d2425242500252424001b1a250025251b1a1b3c5464003b3b353f003b3b643d643c64
117050505050135014000000000000000000001010101210101213140000000000000000000000001200000000121111111112101114000058000058000012111b1a5252621a1b1e1d24251d001a1a1b1b0000001d00000000241d002500001e1d1e001d242425241c2400001e001e1b3c3400003a353b34003c3f545464743c
11501050000000000050000000000000000000001414001400000000000000000000000000000000000000001311101211101212100000004d4e4f00000010111b1b6252521a1b5200252425251f000000001d1d001f1a1c1f1d25000000001a1a0000252524251c1b1d000000621d1b3b3f3d34643b3a3b3d003a646454643b
121050000000000000606000500000000000000000000000150000000000001211130000000000001500001211111110111010116000005800000000001512121c1b521b721b1c62521e1d252424001d1f1d00001f241b1b24001e000000621b1a00002424251e1a1b0000000000621b3b546434353c353c35003e3c643e643a
111013600060006050601071605012111000000060500000100000005000121011120000000013111111111110111010101210101113000000000000601212111a1b5262521c1b5262726200252524242524252424252524520000006262521b1c62001e24251d00000000001a52001b3c3b643b34343c003d3f00343c643d3c
101000000050707160501350121110111050000010126000000060000013101011111000001211111212101212111211101110121111501500000013121111101b1b72737273526273526262521b1a1b1a241c1a2524001e005262521b1a1c1c1c520000000000000000001d1f1c1a3b3d3b3b5435353e00743b00006464543c
101100000012111012101010111012111010157160506050005070601512121210101100001110101011121111121111111012111011111110121211111210101b1c1a72731c1a1c1b1b1a1a1b3b3b1a1c251b1a241e1c1b526252521c1c1b1b1b0052006200251c1c1d1f62521b3b3b3a3b3c64643d3f6454343f003d54753b
111200000011101011111210101011111111101010101212111011111210111111111100001010121111111112121011121111101010101210121012121111111b1b1a1e001b1b1a1b1a1c1b3b1a3b3b1a1b1a1b1c1c1b1b1c1a1b1b1b1c1a1b1a1b1a1a1c1c1b24251b1c1a1b3b1a3b3b3b543b3c3c3c3b3a3a3b00003b3a3b
1b1b0000001c1b1b11111b111010111111111011111012111211111110111011111010000010121210101212101012113b3a3b3c3a3a3c3c3b3b3e3b3b3a3a3b1b1b1b00001b1c1c1b1c1c1b1b1c3c3b3b3b3a3c3c3c3a3a3c3a3a3a3c3b3f3b3b3a3a3b1c1b1b25241b1b3e3b3c3b3b3b3a3b3c3b3b3c3c3c3b3a00003b3b00
1b1a0000001a1c1a1b1a11111b11121111121210121011121110121111121111111250000000140013121012111210113b3c3c00343534343c3a3c3c3b3b643b1b1a1c001d1b1b1d6725251f3a3c1b3a3c3d3a3a3b643434543b3b643b3e343a3a3b35541a1a1c24251c1a3a3a3b3c3c3c646454643535345434003f003a003b
1b1e000000001e1d1a1a1b1a1c1b111110121126090926372637263726131011101200000000000000145010121012103c003534003c3534343500643c003b3b1c1a1b1f251b1b242524242524571a3c3c343b343d24253e3a74543b343b3c3c3c3c3b643a643a1e25251d3b3a353b3c3b545464643a3b3564546434003c3b3c
1a1d1f00660000001c1c1c1a1c1c1010121211082806093109320930080014101213000000001500000000001400001400003c35343d3e3f34353434643b3b3a1b1b1b24251a1c1b1a1a1c771a1b3a3b3c3a3e25253434253e3f34343b3c3c3b3b3c3c3b543b353b3b243b3a34543b3b3c743a3b64753b3a003a643435543b00
1c1d7600000076000066001d1e760014000010080606060606060606160000140000000000001012600000000015000000003e3d353b3a3b643434353d3c3a3a1b251b2524252425571f001d24251b1a3c243424353524242534353435343d3e3f3e3c3c3b3b3b3f3b3b253b3b3b3a3a3b35643a3c74753d34340064643d3c3b
1b1d1e00591d000000000000561b111210001308060606060606060617000000000000000000121110000060111011113b000000343c343b3a3b3d34003f3a3b1b241b242400001e1f001d675724251c3b357a3424343524252434353c3a3c3b3b773b3b3b543b3c3c3c3b3b353a3a3b343b3535343a643e3535546474643c3b
1a1e661d00000000001d5900001b1210111300262c09062b363329292a000000000000000000601013000010121010113b3f000000003c3c3b35350034353c3b1b1a1a2567521d001d577752001e1a252524353534347a3434253a3e353b3b3a3c3f353c3c35753a3a3c3b543c3a3a3c3b3b343535346454643434643a64343c
1a6600665600006600001e1d1d1a1a12110000083927060c3806060626000012111000150000005012000012101212113b3b35353d00003e3c3c003d3435003b251a1c1b1b1b1b0067621d1d77001a2524252535347a343424253e3d343b343b3a3534353475743475343435343435353d3d3e3d34356464646434355464543a
1b520056001d1f00001d0076001b1a1112150019180718091918180709000011121012115013000014000000101211103a3c34343500003d0035003c34343d3a1b1b1b1c1c1a1c0000771d001d671b1b3a3b25342534352534242534353a3b3f3c3b54355474756434353434353434353e003d3f643554643a543a3b7554643c
251b6200001a1b001a1c1b1a1a1b1a1b11001300000000140050000014001310101212101110156000000000131212113b343b34643d3c000000003d3e003f3a1b1c1c1b1b1c1b57001e1f5700001c1b3a253b253a35343534253d543b643b3a3c3c3a3b753c3c3c643b54353b643b3b3c3b3b54753434645464753a3a64543b
1b24251d001c1a001b1a1c1b1a1c1b1a10120000005015600000000015131011101111121211111100000000001011113b3b3a3b3b3f3d343f00000000003a3b1c1c1b1a1c1c1b1c1b1c1b1c1b1a1a1b3c3b343b643434252454753b3c3b343a3b3c3a3d3b3c3a3c3c3b3b643c3c3a3c3c3a543b3a3b343a3e3e64353454643a
1c1b24251d1b1a001b1a1a1b1b1a1c1b1110101110101210111011101211101112121212111111121100000000101210003b3b343b3a3a3a3b000000003b3b3b1b1b1c1b1a1a1b1c1c1a1a1b1c1c1a1a3b003b3c3b3b3c3c3a3c3c3c3b3b3e3b3b353b3a3c3b3b3b3a3c3a3c003b3c3b3b3c3b3c003b3b003b3a3b3a3c3b3b64
0000000000000000000000000000000012111112101212101111111210101212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000010111111101211111111111211111010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
990400001301018000180201a0001c000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990400001301017000170201a0000b0000000000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
990400001f020000002b0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91010000180201c0301f030220203c0003c0003c00000000290002800027000240000000027000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000
49010000186701c0601f050220501b0402303026020280100d3000b30009300073000b3000c3000c3000b3000a30009300083000b3000c3000b30000000000000000000000000000000000000000000000000000
55020000133150c625133150c625133150c625133150c6250b31509315053150231501313003000630005600033000260001300006000030009600003000c3000c3000b3000a30009300083000b3000c3000b300
151200000003000010000100001000010000100001000015000100001000010000100001000010000100001500020000100001000010000100001000010000150001000010000100001000010000100001000015
0d1200000c0200c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c0100c015
0d1200000f0200f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f0100f015
0d1200001602016010160101601016010160101601016010160101601016010160101601016010160101601016010160101601016010160101601016010160101601016010160101601016010160101601016015
9904000018010230202d0203902037000390100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9904000018010230202d0203902037000320100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99040000180201f030210301a000245302b5302d52020700305203753039530000000000038700395203370000000347003700037700377003900000000000000000000000000000000000000000000000000000
0d1200001102011010110101101011010110101101011010110101101011010110101101011010110101101011010110101101011010110101101011010110101101011010110101101011010110101101011015
d11200000a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a5120a515
d11200000c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c5120c515
0d1200001802018010180101801018010180101801018010180101801018010180101801018010180101801018010180101801018010180101801018010180101801018010180101801018010180101801018015
151200000004000010000300001000020000100002000015000100001000010000100001000010000100001500030000100001000010000100001000010000150002000010000100001000010000100001000015
0304000025610276302764026630236301f62018610136100d6000660004600016000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03060000106400c600106500c600106400c6001063000000000040000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
900200001061000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c00200001263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490400001c6600f030056300803003620050200261002020016100102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d0400000c020130200c02013020180201f0300000021040005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910300001903002600026000360004600046000560006600076000860008600086000860007600066000560004600036000260001600016000000000000000000000000000000000000000000000000000000000
030c00003a6113c6123d6123d6123d6123d6123d6123d6123d6123d6123d6123d6150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d50900000c6310c0310c0220c0220c0220c0220c0220c0220c0220c0120c0120c0120c0120c0120c0120c0120c0000c0000c0000c0000c0000c0000c0000c0000000000000000000000000000000000000000000
99040000000001801000000000001f030390003700024020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9904000000000000003002037030390301a0003003037030390203870030030370303902037000377003770039000000000000000000000000000000000000000000000000000000000000000000000000000000
9904000000000000003002000000000001a0002403038700370003770037700390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 4642114e
01 464e060e
00 4648060f
00 4647060e
00 464d060f
00 46471108
00 46480607
00 4647110d
00 46480607
00 46471109
00 46481110
00 41421109
02 41420607


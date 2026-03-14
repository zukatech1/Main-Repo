print("made by zuka hooking into the adonis core.client")
print("updated on march 13 fri 10:35pm"
local Byte         = string.byte;
local Char         = string.char;
local Sub          = string.sub;
local Concat       = table.concat;
local LDExp        = math.ldexp;
local GetFEnv      = getfenv or function() return _ENV end;
local Setmetatable = setmetatable;
local Select       = select;
local Unpack = unpack;
local ToNumber = tonumber;local function decompress(b)local c,d,e="","",{}local f=256;local g={}for h=0,f-1 do g[h]=Char(h)end;local i=1;local function k()local l=ToNumber(Sub(b, i,i),36)i=i+1;local m=ToNumber(Sub(b, i,i+l-1),36)i=i+l;return m end;c=Char(k())e[1]=c;while i<#b do local n=k()if g[n]then d=g[n]else d=c..Sub(c, 1,1)end;g[f]=c..Sub(d, 1,1)e[#e+1],c,f=d,d,f+1 end;return table.concat(e)end;local ByteString=decompress('1214275151E2751422W22Z22T22O23B23423A23122Y22R151027922R22T22X22P151327922423423423821V22P2341522A27923027W23823B21Q21721723A22T23721622R23123423023522U23523B22P23A22V22Z22Y23422P28S21628Q22X21723I23523322T28T22V23021H21722122T27I21522E22P23822Z28B22P22Q23B21723022P27D29K22X29A22Y21721Y23H22P29U22P21X22O28R23123B21622W23522T151127923827H28S151G27922Q23522V23321023H22Z23521027D2A123B21022Y22Z22Z22U141F2792321C26S26Z22U1C27522Y1K2B32321K27522Z1C21G142B127522Q2102BA2102BD1S2752322BP14233142BN2322792331C2BC2BI2BH2182BA2182B721G2BA2BG2BT1K2C12BC2BT2B61422Y2CG27914');
local BitXOR = bit and bit.bxor or function(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end
local function gBit(Bit, Start, End)
	if End then
		local Res = (Bit / 2 ^ (Start - 1)) % 2 ^ ((End - 1) - (Start - 1) + 1);
		return Res - Res % 1;
	else
		local Plc = 2 ^ (Start - 1);
        return (Bit % (Plc + Plc) >= Plc) and 1 or 0;
	end;
end;
local Pos = 1;
local function gBits32()
    local W, X, Y, Z = Byte(ByteString, Pos, Pos + 3);
	W = BitXOR(W, 4)
	X = BitXOR(X, 4)
	Y = BitXOR(Y, 4)
	Z = BitXOR(Z, 4)
    Pos	= Pos + 4;
    return (Z*16777216) + (Y*65536) + (X*256) + W;
end;
local function gBits8()
    local F = BitXOR(Byte(ByteString, Pos, Pos), 4);
    Pos = Pos + 1;
    return F;
end;
local function gFloat()
	local Left = gBits32();
	local Right = gBits32();
	local IsNormal = 1;
	local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32))
					+ Left;
	local Exponent = gBit(Right, 21, 31);
	local Sign = ((-1) ^ gBit(Right, 32));
	if (Exponent == 0) then
		if (Mantissa == 0) then
			return Sign * 0;
		else
			Exponent = 1;
			IsNormal = 0;
		end;
	elseif (Exponent == 2047) then
        return (Mantissa == 0) and (Sign * (1 / 0)) or (Sign * (0 / 0));
	end;
	return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
end;
local gSizet = gBits32;
local function gString(Len)
    local Str;
    if (not Len) then
        Len = gSizet();
        if (Len == 0) then
            return '';
        end;
    end;
    Str	= Sub(ByteString, Pos, Pos + Len - 1);
    Pos = Pos + Len;
	local FStr = {}
	for Idx = 1, #Str do
		FStr[Idx] = Char(BitXOR(Byte(Sub(Str, Idx, Idx)), 4))
	end
    return Concat(FStr);
end;
local gInt = gBits32;
local function _R(...) return {...}, Select('#', ...) end
local function Deserialize()
    local Instrs = { 0,0,0,0,0,0,0,0,0,0,0 };
    local Functions = {  };
	local Lines = {};
    local Chunk = 
	{
		Instrs,
		nil,
		Functions,
		nil,
		Lines
	};
								local ConstCount = gBits32()
    							local Consts = {0,0,0,0,0,0};
								for Idx=1,ConstCount do 
									local Type=gBits8();
									local Cons;
									if(Type==2) then Cons=(gBits8() ~= 0);
									elseif(Type==3) then Cons = gFloat();
									elseif(Type==1) then Cons=gString();
									end;
									Consts[Idx]=Cons;
								end;
								Chunk[2] = Consts
								Chunk[4] = gBits8();for Idx=1,gBits32() do 
									local Data1=BitXOR(gBits32(),107);
									local Data2=BitXOR(gBits32(),106); 
									local Type=gBit(Data1,1,2);
									local Opco=gBit(Data2,1,11);
									local Inst=
									{
										Opco,
										gBit(Data1,3,11),
										nil,
										nil,
										Data2
									};
									if (Type == 0) then Inst[3]=gBit(Data1,12,20);Inst[5]=gBit(Data1,21,29);
									elseif(Type==1) then Inst[3]=gBit(Data2,12,33);
									elseif(Type==2) then Inst[3]=gBit(Data2,12,32)-1048575;
									elseif(Type==3) then Inst[3]=gBit(Data2,12,32)-1048575;Inst[5]=gBit(Data1,21,29);
									end;
									Instrs[Idx]=Inst;end;for Idx=1,gBits32() do Functions[Idx-1]=Deserialize();end;return Chunk;end;
local function Wrap(Chunk, Upvalues, Env)
	local Instr  = Chunk[1];
	local Const  = Chunk[2];
	local Proto  = Chunk[3];
	local Params = Chunk[4];
	return function(...)
		local Instr  = Instr; 
		local Const  = Const; 
		local Proto  = Proto; 
		local Params = Params;
		local _R = _R
		local InstrPoint = 1;
		local Top = -1;
		local Vararg = {};
		local Args	= {...};
		local PCount = Select('#', ...) - 1;
		local Lupvals	= {};
		local Stk		= {};
		for Idx = 0, PCount do
			if (Idx >= Params) then
				Vararg[Idx - Params] = Args[Idx + 1];
			else
				Stk[Idx] = Args[Idx + 1];
			end;
		end;
		local Varargsz = PCount - Params + 1
		local Inst;
		local Enum;	
		while true do
			Inst		= Instr[InstrPoint];
			Enum		= Inst[1];if Enum <= 3 then if Enum <= 1 then if Enum == 0 then Stk[Inst[2]]=Const[Inst[3]];else local A=Inst[2];local Args={};local Edx=0;local Limit=A+Inst[3]-1;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;local Results,Limit=_R(Stk[A](Unpack(Args,1,Limit-A)));Limit=Limit+A-1;Edx=0;for Idx=A,Limit do Edx=Edx+1;Stk[Idx]=Results[Edx];end;Top=Limit;end; elseif Enum == 2 then Stk[Inst[2]]();Top=A;else local A=Inst[2];local Args={};local Edx=0;local Limit=A+Inst[3]-1;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;Stk[A](Unpack(Args,1,Limit-A));Top=A;end; elseif Enum <= 5 then if Enum > 4 then local A=Inst[2];local B=Stk[Inst[3]];Stk[A+1]=B;Stk[A]=B[Const[Inst[5]]];else do return end;end; elseif Enum <= 6 then Stk[Inst[2]]=Env[Const[Inst[3]]]; elseif Enum == 7 then local A=Inst[2];local Args={};local Edx=0;local Limit=Top;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;local Results={Stk[A](Unpack(Args,1,Limit-A))};local Limit=A+Inst[5]-2;Edx=0;for Idx=A,Limit do Edx=Edx+1;Stk[Idx]=Results[Edx];end;Top=Limit;else local Results;local Results,Limit;local Limit;local Edx;local Args;local B;local A;Stk[Inst[2]]=Env[Const[Inst[3]]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]=Env[Const[Inst[3]]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];A=Inst[2];B=Stk[Inst[3]];Stk[A+1]=B;Stk[A]=B[Const[Inst[5]]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]=Const[Inst[3]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];A=Inst[2];Args={};Edx=0;Limit=A+Inst[3]-1;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;Results,Limit=_R(Stk[A](Unpack(Args,1,Limit-A)));Limit=Limit+A-1;Edx=0;for Idx=A,Limit do Edx=Edx+1;Stk[Idx]=Results[Edx];end;Top=Limit;InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];A=Inst[2];Args={};Edx=0;Limit=Top;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;Results={Stk[A](Unpack(Args,1,Limit-A))};Limit=A+Inst[5]-2;Edx=0;for Idx=A,Limit do Edx=Edx+1;Stk[Idx]=Results[Edx];end;Top=Limit;InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]();Top=A;InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]=Env[Const[Inst[3]]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];Stk[Inst[2]]=Const[Inst[3]];InstrPoint = InstrPoint + 1;Inst = Instr[InstrPoint];A=Inst[2];Args={};Edx=0;Limit=A+Inst[3]-1;for Idx=A+1,Limit do Edx=Edx+1;Args[Edx]=Stk[Idx];end;Stk[A](Unpack(Args,1,Limit-A));Top=A;end;
			InstrPoint	= InstrPoint + 1;
		end;
    end;
end;	
return Wrap(Deserialize(), {}, GetFEnv())();

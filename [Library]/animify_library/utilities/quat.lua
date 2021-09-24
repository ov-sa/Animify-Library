  
----------------------------------------------------------------
--[[ Resource: Animify Library
     Script: utilities: client.lua
     Server: -
     Author: OvileAmriam
     Developer: Deltanic, Exile
     DOC: 08/09/2021 (OvileAmriam)
     Desc: Quaternion Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    math = {
        abs = math.abs,
        sqrt  = math.sqrt,
        exp = math.exp,
        log = math.log,
        sin = math.sin,
        cos = math.cos,
        acos = math.acos
    }
}


-------------------
--[[ Variables ]]--
-------------------

local constants = {
    deg2Rad = math.pi/180,
    rad2deg = 180/math.pi,
    delta = 0.0000001000000
}

Quaternion = {}
Quaternion.__index = Quaternion


------------------------------------------------
--[[ Functions: Intializes Quaternion Class ]]--
------------------------------------------------

function Quaternion.new(q,r,s,t)

	return setmetatable({q,r,s,t},Quaternion)

end

local function qmul(lhs, rhs)

	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return Quaternion.new(
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	)

end
Quaternion.__mul = qmul

local function qexp(q)

	local m = imports.math.sqrt(q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	local u1, u2, u3 = 0, 0, 0
	if m ~= 0 then
		u1 = q[2]*imports.math.sin(m)/m
		u2 = q[3]*imports.math.sin(m)/m
		u3 = q[4]*imports.math.sin(m)/m
	end
	local r = imports.math.exp(q[1])
	return Quaternion.new(r*imports.math.cos(m), r*u1, r*u2, r*u3)

end

local function qlog(q)

	local l = imports.math.sqrt(q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	if l == 0 then return { -1e+100, 0, 0, 0 } end
	local u2, u3, u4 = q[2]/l, q[3]/l, q[4]/l -- u1 is never used
	local a = imports.math.acos(u[1])
	local m = imports.math.sqrt(u2*u2 + u3*u3 + u4*u4)
	if imports.math.abs(m) > constants.delta then
		return Quaternion.new( imports.math.log(l), a*u2/m, a*u3/m, a*u4/m )
	else
		return Quaternion.new( imports.math.log(l), 0, 0, 0 )  --when m is 0, u[2], u[3] and u[4] are 0 too
	end

end
Quaternion.log = qlog

--- Converts <ang> to a quaternion
function Quaternion.fromAngle(ang)

	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {imports.math.cos(r), imports.math.sin(r), 0, 0}
	local qp = {imports.math.cos(p), 0, imports.math.sin(p), 0}
	local qy = {imports.math.cos(y), 0, 0, imports.math.sin(y)}
	return qmul(qy,qmul(qp,qr))

end

function Quaternion.fromVectors(forward, up)

	local x = forward
	local z = up
	local y = z:Cross(x):GetNormalized() --up x forward = left
	
	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end
	
	local yyaw = Vector3(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))
	
	local roll = imports.math.acos(y:Dot(yyaw))*constants.rad2deg
	
	local dot = y:Dot(z)
	if dot < 0 then roll = -roll end
	
	local p, y, r = ang.p, ang.y, roll
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {imports.math.cos(r), imports.math.sin(r), 0, 0}
	local qp = {imports.math.cos(p), 0, imports.math.sin(p), 0}
	local qy = {imports.math.cos(y), 0, 0, imports.math.sin(y)}
	return qmul(qy,qmul(qp,qr))

end

--- Returns quaternion for rotation about axis <axis> by angle <ang>. If ang is left out, then it is computed as the magnitude of <axis>
function Quaternion.fromRotation(axis, ang)

	if ang then
		axis:Normalize()
		local ang2 = ang*deg2rad*0.5
		return Quaternion.new( imports.math.cos(ang2), axis.x*imports.math.sin(ang2), axis.y*imports.math.sin(ang2), axis.z*imports.math.sin(ang2) )
	else
		local angSquared = axis:LengthSqr()
		if angSquared == 0 then return Quaternion.new( 1, 0, 0, 0 ) end
		local len = imports.math.sqrt(angSquared)
		local ang = (len + 180) % 360 - 180
		local ang2 = ang*deg2rad*0.5
		local sang2len = imports.math.sin(ang2) / len
		return Quaternion.new( imports.math.cos(ang2), rv1[1] * sang2len , rv1[2] * sang2len, rv1[3] * sang2len )
	end

end

function Quaternion:__neg()

	return Quaternion.new( -self[1], -self[2], -self[3], -self[4] )

end

function Quaternion.__add(lhs, rhs)

	return Quaternion.new( lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] )

end

function Quaternion.__sub(lhs, rhs)

	return Quaternion.new( lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] )

end

function Quaternion.__mul(lhs, rhs)

	if type(rhs) == "number" then
		return Quaternion.new( rhs * lhs[1], rhs * lhs[2], rhs * lhs[3], rhs * lhs[4] )
	elseif type(rhs) == "Vector3" then
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs2, rhs3, rhs4 = rhs.x, rhs.y, rhs.z
		return Quaternion.new(
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			 lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			 lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			 lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
		)
	else
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		return Quaternion.new(
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
		)
	end

end

function Quaternion.__div(lhs, rhs)

	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	return Quaternion.new(
		lhs1/rhs,
		lhs2/rhs,
		lhs3/rhs,
		lhs4/rhs
	)

end

function Quaternion.__pow(lhs, rhs)

	local l = qlog(lhs)
	return qexp({ l[1]*rhs, l[2]*rhs, l[3]*rhs, l[4]*rhs })

end

function Quaternion.__eq(lhs, rhs)

	if getmetatable(lhs) ~= Quaternion or getmetatable(lhs) ~= getmetatable(rhs) then return false end

	local rvd1, rvd2, rvd3, rvd4 = lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4]
	return rvd1 <= constants.delta and rvd1 >= -constants.delta and
	   rvd2 <= constants.delta and rvd2 >= -constants.delta and
	   rvd3 <= constants.delta and rvd3 >= -constants.delta and
	   rvd4 <= constants.delta and rvd4 >= -constants.delta

end

--- Returns absolute value of self
function Quaternion:abs()

	return imports.math.sqrt(self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4])

end

--- Returns the conjugate of self
function Quaternion:conj()

	return Quaternion.new(self[1], -self[2], -self[3], -self[4])

end

--- Returns the inverse of self
function Quaternion:inv()

	local l = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	return Quaternion.new( self[1]/l, -self[2]/l, -self[3]/l, -self[4]/l )

end


--- Raises Euler's constant e to the power self
function Quaternion:exp()

	return qexp(self)

end

--- Calculates natural logarithm of self
function Quaternion:log()

	return qlog(self)

end

--- Changes quaternion <self> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)
function Quaternion:mod()

	if self[1]<0 then
        return Quaternion.new(-self[1], -self[2], -self[3], -self[4])
    else
        return Quaternion.new(self[1], self[2], self[3], self[4])
    end

end

--- Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1
function Quaternion.slerp(q0, q1, t)

	local dot = q0[1]*q1[1] + q0[2]*q1[2] + q0[3]*q1[3] + q0[4]*q1[4]
	local q11
	if dot<0 then
		q11 = {-q1[1], -q1[2], -q1[3], -q1[4]}
	else
		q11 = { q1[1], q1[2], q1[3], q1[4] }  -- dunno if just q11 = q1 works
	end
	
	local l = q0[1]*q0[1] + q0[2]*q0[2] + q0[3]*q0[3] + q0[4]*q0[4]
	if l == 0 then
        return { 0, 0, 0, 0 }
    end
	local invq0 = { q0[1]/l, -q0[2]/l, -q0[3]/l, -q0[4]/l }
	local logq = qlog(qmul(invq0,q11))
	local q = qexp( { logq[1]*t, logq[2]*t, logq[3]*t, logq[4]*t } )
	return qmul(q0,q)

end

--- Returns Vector3 pointing forward for <self>
function Quaternion:forward()

	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return {
		this1 * this1 + this2 * this2 - this3 * this3 - this4 * this4,
		t3 * this2 + t4 * this1,
		t4 * this2 - t3 * this1
	}

end

--- Returns Vector3 pointing right for <self>
function Quaternion:right()

	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return Vector3(
		t4 * this1 - t2 * this3,
		this2 * this2 - this1 * this1 + this4 * this4 - this3 * this3,
		- t2 * this1 - t3 * this4
	)

end

--- Returns Vector3 pointing up for <self>
function Quaternion:up()

	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2
	return Vector3(
		t3 * this1 + t2 * this4,
		t3 * this4 - t2 * this1,
		this1 * this1 - this2 * this2 - this3 * this3 + this4 * this4
	)

end

--- Returns the angle of rotation in degrees
function Quaternion:rotationAngle()

	local l2 = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	if l2 == 0 then
        return 0
    end
	local l = imports.math.sqrt(l2)
	local ang = 2*imports.math.acos(self[1]/l)*constants.rad2deg  --this returns angle from 0 to 360
	if ang > 180 then ang = ang - 360 end  --make it -180 - 180
	return ang

end

--- Returns the axis of rotation
function Quaternion:rotationAxis()

	local m2 = self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	if m2 == 0 then return Vector3( 0, 0, 1 ) end
	local m = imports.math.sqrt(m2)
	return Vector3( self[2] / m, self[3] / m, self[4] / m)

end

--- Returns angle represented by <self>
function Quaternion:toAngle()

	local l = imports.math.sqrt(self[1]*self[1]+self[2]*self[2]+self[3]*self[3]+self[4]*self[4])
	local q1, q2, q3, q4 = self[1]/l, self[2]/l, self[3]/l, self[4]/l
	local x = Vector3(q1*q1 + q2*q2 - q3*q3 - q4*q4, 2*q3*q2 + 2*q4*q1, 2*q4*q2 - 2*q3*q1)
	local y = Vector3(2*q2*q3 - 2*q4*q1, q1*q1 - q2*q2 + q3*q3 - q4*q4, 2*q2*q1 + 2*q3*q4)
	local ang = x:Angle()

	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end
	local yyaw = Vector3(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))

	local roll = imports.math.acos(y:Dot(yyaw))*constants.rad2deg
	local dot = q2*q1 + q3*q4
	if dot < 0 then roll = -roll end
	return Angle(ang.p, ang.y, roll)

end

function Quaternion:__tostring()

	return string.format("<%d,%d,%d,%d>",self[1],self[2],self[3],self[4])

end



---------MTA RELATED STUFFS FROM HERE---------

function Clamp(x, minA, maxA)

  return math.min(math.max(x, minA), maxA)

end

function EulerToQuaternion(rotX, rotY, rotZ)

    local radX = math.rad(rotX) * 0.5
    local radY = math.rad(rotY) * 0.5
    local radZ = math.rad(rotZ) * 0.5
    local cosX = imports.math.cos(radX)
    local sinX = imports.math.sin(radX)
    local cosY = imports.math.cos(radY)
    local sinY = imports.math.sin(radY)
    local cosZ = imports.math.cos(radZ)
    local sinZ = imports.math.sin(radZ)

    local w = cosZ * cosX * cosY + sinZ * sinX * sinY
    local x = cosZ * sinX * cosY - sinZ * cosX * sinY
    local y = cosZ * cosX * sinY + sinZ * sinX * cosY
    local z = sinZ * cosX * cosY - cosZ * sinX * sinY
    return Quaternion.new(w, x, y, z);

end

function QuaternionToEuler(w, x, y, z)

    local sinX = 2.0 * (w * x + y * z)
    local cosX = 1.0 - (2.0 * (x * x + y * y))
    local rotX = math.deg(math.atan2(sinX, cosX))
    local sinY = 2.0 * (w * y - z * x)
    local fixY = Clamp(sinY, -1.0, 1.0)
    local rotY = math.deg(math.asin(fixY))
  
    local sinZ = 2.0 * (w * z + x * y)
    local cosZ = 1.0 - (2.0 * (y * y + z * z))
    local rotZ = math.deg(math.atan2(sinZ, cosZ))
    return Vector3(rotX, rotY, rotZ)

end

function quat(angle, vec)

    local a = angle * (0.5 * math.pi / 180.0)
    local s = imports.math.sin(a)
    local w = imports.math.cos(a)
  
    return Quaternion.new(w, s * vec.x, s * vec.y, s * vec.z)

end

function ApplyElementRotation(element, rotX, rotY, rotZ, relativeToWorld)

    if rotX == 0.0 and rotY == 0.0 and rotZ == 0.0 then
        return
    end
    local x, y, z = getElementRotation(element, 'ZYX')
    local inQuat = EulerToQuaternion(x, y, z)
  
    local vecX = Vector3(1, 0, 0)
    local vecY = Vector3(0, 1, 0)
    local vecZ = Vector3(0, 0, 1)
  
    if relativeToWorld then
      local rotQuat = quat(rotX, vecX)*quat(rotY, vecY)*quat(rotZ, vecZ) 
      inQuat = rotQuat * inQuat
    else
      inQuat = inQuat * quat(rotX, vecX)
      inQuat = inQuat * quat(rotY, vecY)
      inQuat = inQuat * quat(rotZ, vecZ)
    end
    local rot = QuaternionToEuler(inQuat[1], inQuat[2], inQuat[3], inQuat[4])
    setElementRotation(element,rot.x,rot.y,rot.z, 'ZYX')

end

--TODO: USE & FIX THIS...
function ApplyElementBoneRotation(element, boneID, rotX, rotY, rotZ, relativeToWorld)

    if rotX == 0.0 and rotY == 0.0 and rotZ == 0.0 then
        return
    end

    local z, x, y = getElementBoneRotation(element, boneID)
    local inQuat = EulerToQuaternion(x, y, z)
    local vecX = Vector3(1, 0, 0)
    local vecY = Vector3(0, 1, 0)
    local vecZ = Vector3(0, 0, 1)
    if relativeToWorld then
        local rotQuat = quat(rotZ, vecZ) * quat(rotX, vecX) * quat(rotY, vecY)
        inQuat = rotQuat * inQuat
    else
        inQuat = inQuat * quat(rotX, vecX)
        inQuat = inQuat * quat(rotY, vecY)
        inQuat = inQuat * quat(rotZ, vecZ)
    end
    local rot = QuaternionToEuler(inQuat[1], inQuat[2], inQuat[3], inQuat[4])
    return rot
  
end
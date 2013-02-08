/********************************************
*         Trajectory by ~Cueball~           *
*                                           *
*     Use this include however you like,    *
*      and contact me via the forum if      *
*          you have any problems.           *
********************************************/

#if defined _trajectory_included
    #endinput
#endif
#define _trajectory_included

#include <a_samp>

forward Float:GetFlightMaxTime(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8); // To avoid reparse errors.

/*
native GetFlightData(Float:base, Float:velocity, Float:angle, fData[][FLIGHT_DATA], points = sizeof(fData), Float:gravity = 9.8);
native GetFlightConditionsAtDistance(Float:base, Float:velocity, Float:angle, Float:distance, &Float:time, &Float:height, &Float:x, &Float:y, Float:gravity = 9.8);
native GetFlightConditionsAtTime(Float:base, Float:velocity, Float:angle, Float:time, &Float:distance, &Float:height, &Float:x, &Float:y, Float:gravity = 9.8);
native GetFlightInitialVelocity(Float:velocity, Float:angle, &Float:x, &Float:y);
native Float:GetFlightMaxHeight(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8);
native Float:GetFlightMaxRange(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8);
native Float:GetFlightMaxTime(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8);
native Float:GetRequiredAngle(Float:range, Float:velocity, Float:gravity = 9.8);
native GetRequiredConditions(Float:range, Float:peak, &Float:velocity, &Float:angle, Float:gravity = 9.8);
native Float:GetRequiredVelocity(Float:range, Float:angle, Float:gravity = 9.8);
native Float:GetVelocity(Float:x, Float:y);
*/

enum FLIGHT_DATA {
    Float:FLIGHT_DISTANCE,
    Float:FLIGHT_HEIGHT,
    Float:FLIGHT_VELOCITYX,
    Float:FLIGHT_VELOCITYY
}

stock GetFlightData(Float:base, Float:velocity, Float:angle, fData[][FLIGHT_DATA], points = sizeof(fData), Float:gravity = 9.8)
{
    for(new i, Float:increment = floatdiv(GetFlightMaxTime(base, velocity, angle, gravity), float(points)), Float:cTime = increment; i < points; i++, cTime += increment)
        GetFlightConditionsAtTime(base, velocity, angle, cTime, fData[i][FLIGHT_DISTANCE], fData[i][FLIGHT_HEIGHT], fData[i][FLIGHT_VELOCITYX], fData[i][FLIGHT_VELOCITYY], gravity);
}

stock GetFlightConditionsAtDistance(Float:base, Float:velocity, Float:angle, Float:distance, &Float:time, &Float:height, &Float:x, &Float:y, Float:gravity = 9.8)
{
    GetFlightInitialVelocity(velocity, angle, x, y);
    time = floatdiv(distance, x);
    height = floatadd(base, floatdiv(floatmul(distance, y), x) - floatmul(0.5, floatmul(gravity, floatdiv(floatpower(distance, 2.0), floatpower(x, 2.0)))));
    y -= floatmul(gravity, time);
}

stock GetFlightConditionsAtTime(Float:base, Float:velocity, Float:angle, Float:time, &Float:distance, &Float:height, &Float:x, &Float:y, Float:gravity = 9.8)
{
    distance = floatmul(floatmul(velocity, floatcos(angle, degrees)), time);
    height = floatadd(base, floatsub(floatmul(floatmul(velocity, floatsin(angle, degrees)), time), floatdiv(floatmul(gravity, floatpower(time, 2.0)), 2.0)));
    GetFlightInitialVelocity(velocity, angle, x, y);
    y -= floatmul(gravity, time);
}

stock GetFlightInitialVelocity(Float:velocity, Float:angle, &Float:x, &Float:y)
{
    x = floatmul(velocity, floatcos(angle, degrees));
    y = floatmul(velocity, floatsin(angle, degrees));
}

stock Float:GetFlightMaxHeight(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8)
{
    new Float:x, Float:y;
    GetFlightInitialVelocity(velocity, angle, x, y);
    
    return floatadd(base, floatdiv(floatpower(y, 2.0), floatmul(2.0, gravity)));
}

stock Float:GetFlightMaxRange(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8)
{
    new Float:x, Float:y, Float:t = GetFlightMaxTime(base, velocity, angle, gravity);
    GetFlightInitialVelocity(velocity, angle, x, y);
    
    return floatmul(x, t);
}

stock Float:GetFlightMaxTime(Float:base, Float:velocity, Float:angle, Float:gravity = 9.8)
{
    new Float:x, Float:y, Float:fTimes[2];
    GetFlightInitialVelocity(velocity, angle, x, y);

    fTimes[0] = floatadd(floatdiv(y, gravity), floatsqroot(floatsub(floatdiv(floatpower(y, 2.0), floatpower(gravity, 2.0)), floatdiv(floatmul(base, 2.0), gravity))));
    fTimes[1] = floatsub(floatdiv(y, gravity), floatsqroot(floatsub(floatdiv(floatpower(y, 2.0), floatpower(gravity, 2.0)), floatdiv(floatmul(base, 2.0), gravity))));

    return (fTimes[0] >= fTimes[1]) ? (fTimes[0]) : (fTimes[1]);
}

stock Float:GetRequiredAngle(Float:range, Float:velocity, Float:gravity = 9.8)
{
    return floatdiv(asin(floatdiv(floatmul(range, gravity), floatpower(velocity, 2.0))), 2.0);
}

stock GetRequiredConditions(Float:range, Float:peak, &Float:velocity, &Float:angle, Float:gravity = 9.8)
{
    velocity = floatsqroot(floatdiv(floatmul(range, gravity), floatsin(floatmul(2.0, atan(floatmul(4.0, floatdiv(peak, range)))), degrees)));
    angle = floatdiv(floatmul(atan(floatmul(4.0, floatdiv(peak, range))), 180.0), floatdiv(22.0, 7.0));
}

stock Float:GetRequiredVelocity(Float:range, Float:angle, Float:gravity = 9.8)
{
    return floatsqroot(floatdiv(floatmul(range, gravity), floatsin(floatmul(2.0, angle), degrees)));
}

stock Float:GetVelocity(Float:x, Float:y)
{
    return floatsqroot(floatadd(floatpower(x, 2.0), floatpower(y, 2.0)));
}

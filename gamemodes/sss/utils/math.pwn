/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2016 "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


forward Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z);
forward Float:Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
forward Float:Distance2D(Float:x1, Float:y1, Float:x2, Float:y2);
forward Float:absoluteangle(Float:angle);

/*
	Distance between 2 points in 3D space
*/
stock Float:Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
	return floatsqroot((((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))+((z1-z2)*(z1-z2))));

/*
	Distance between 2 points in 2D space
*/
stock Float:Distance2D(Float:x1, Float:y1, Float:x2, Float:y2)
	return floatsqroot( ((x1-x2)*(x1-x2)) + ((y1-y2)*(y1-y2)) );

/*
	Returns the absolute value of an angle
*/
stock Float:absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;
	return angle;
}


/*
	Separates the digits from a decimal value and saves them to an array
	Credits - RyDeR` (http://forum.sa-mp.com/showpost.php?s=df579e9e90d575ae4911cda03598929f&p=1277125&postcount=2168)
*/
stock GetDigits(const value, strDig[])
{
	valstr(strDig, value, true);
	
	for(new i; strDig{i} != EOS; i++)
		strDig{i} -= '0';
}

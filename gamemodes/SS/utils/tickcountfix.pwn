/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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


stock intdiffabs(tick1, tick2)
{
	if(tick1 > tick2)
		return abs(tick1 - tick2);

	else
		return abs(tick2 - tick1);
}

stock GetTickCountDifference(a, b)
{
	if ((a < 0) && (b > 0))
	{

		new dist;

		dist = intdiffabs(a, b);

		if(dist > 2147483647)
			return intdiffabs(a - 2147483647, b - 2147483647);

		else
			return dist;
	}

	return intdiffabs(a, b);
}

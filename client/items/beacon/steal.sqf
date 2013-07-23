//@file Version: 1.0
//@file Name: steal.sqf
//@file Author: MercyfulFate
//@file Created: 21/7/2013 16:00
//@file Description: Steal the nearest Spawn Beacon
//@file Argument: [player, player, _action, []] the standard "called by an action" values

#include "mutex.sqf"
#define ANIM "AinvPknlMstpSlayWrflDnon_medic"
#define ERR_IN_VEHICLE "Stealing Spawn Beacon Failed! You can't do this in a vehicle"
#define ERR_NOT_OPP_SIDE "Stealing Spawn Beacon Failed! Someone else finished stealing it first."
#define ERR_TOO_FAR_AWAY "Stealing Spawn Beacon Failed! You are too far away to do that."
#define ERR_CANCELLED "Stealing Spawn Beacon Cancelled"
private ["_beacon", "_error", "_hasFailed", "_success"];

private "_error";
_beacon = [] call mf_items_spawn_beacon_nearest;
_error = [_beacon] call mf_items_spawn_beacon_can_steal;
if (_error != "") exitWith {[_error, 5] call mf_notify_client};

_hasFailed = {
	private ["_progress", "_beacon", "_failed", "_text"];
	_progress = _this select 0;
	_beacon = _this select 1;
	_text = "";
	_failed = true;
	switch (true) do {
		case not(alive player): {};
		case not(vehicle player == player): {_text = ERR_IN_VEHICLE};
		case not((_beacon getVariable["side", ""]) != playerSide): {_error = ERR_NOT_OPP_SIDE};
		case not(player distance _beacon < 5): {_text = ERR_TOO_FAR_AWAY;};
		case (doCancelAction): {doCancelAction = false; _text = ERR_CANCELLED;};
		default {
			_text = format["Stealing %1%2 Complete", round(_progress*100), "%"];
			_failed = false;
		};
	};
	[_failed, _text];
};
MUTEX_LOCK_OR_FAIL;
_success =  [MF_ITEMS_SPAWN_BEACON_STEAL_DURATION, ANIM, _hasFailed, [_beacon]] call mf_util_playUntil;
MUTEX_UNLOCK;

if (_success) then {
    pvar_spawn_beacons = pvar_spawn_beacons - [_beacon];
    publicVariable "pvar_spawn_beacons";
    deleteVehicle _beacon;
    [MF_ITEMS_SPAWN_BEACON, 1] call mf_inventory_add;
	["You have successfully stolen the Spawn Beacon",5] call mf_notify_client;
};
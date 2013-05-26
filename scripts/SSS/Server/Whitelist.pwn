stock AddNameToWhitelist(name[])
{
	new query[128];

	format(query, sizeof(query), "INSERT INTO `Whitelist` (`"#ROW_NAME"`) VALUES('%s')", name);
	db_free_result(db_query(gAccounts, query));

	return 1;
}

stock RemoveNameFromWhitelist(name[])
{
	new query[128];

	format(query, sizeof(query), "DELETE FROM `Whitelist` WHERE `"#ROW_NAME"` = '%s'", name);
	db_free_result(db_query(gAccounts, query));

	return 1;
}

stock IsNameInWhitelist(name[])
{
	new
		query[128],
		DBResult:result,
		numrows;

	format(query, sizeof(query), "SELECT * FROM `Whitelist` WHERE `"#ROW_NAME"` = '%s'", name);
	result = db_query(gAccounts, query);
	numrows = db_num_rows(result);
	db_free_result(result);

	if(numrows > 0)
		return 1;

	return 0;
}

stock AddAllAccountsToWhitelist()
{
	new
		DBResult:result,
		numrows,
		name[MAX_PLAYER_NAME];

	result = db_query(gAccounts, "SELECT * FROM `Player`");
	numrows = db_num_rows(result);

	for(new i; i < numrows; i++)
	{
		db_get_field(result, 0, name, 24);
		printf("Adding to whitelist: '%s'", name);
		AddNameToWhitelist(name);
		db_next_row(result);
	}

	db_free_result(result);
}

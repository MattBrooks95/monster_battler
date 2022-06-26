<script>
export let monster;
</script>

<div class="monsterTile">
	<div>HP</div>
	<div>SPE</div>
	<div>ATT</div>
	<div>DEF</div>
	<div>SPA</div>
	<div>SPD</div>
	<div>ABIL</div>
	<div>
		<span>Types</span>
		<div class="flexRow">
			{#each monster.types as type}
			<div>{type}</div>
			{/each}
		</div>
	</div>
</div>

<style>
.monsterTile {
	display: flex;
	flex-direction: column;
	gap: 8px;
	align-items: center;
}

.flexRow {
	display: flex;
	flex-direction: row;
	gap: 8px;
}
</style>


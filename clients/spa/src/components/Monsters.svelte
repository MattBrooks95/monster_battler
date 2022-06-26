<script>
import { onMount } from 'svelte';

import MonsterTile from "./MonsterTile.svelte";

let monsters = [];
onMount(async () => {
	monsters = [
		{ types: ["Astral", "Fire"] },
		{ types: ["Poison", "Beast"] },
		{ types: ["Fighting"] },
		{ types: ["Primal", "Flying"] },
		{ types: ["Water"], }
	];
});

//onMount(async () => {
//	const response = await fetch('api/monster', {
//		method: 'GET'
//	});
//
//	const respJson = await response.json();
//	monsters = respJson
//
//});

</script>

<div>Monsters List</div>
<div class="monsterGrid">
	{#each monsters as monster}
	<MonsterTile monster={monster} />
	{/each}
</div>

<style>
.monsterGrid {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	gap: 8px;
}

/* you cannot just do .myClass > *, if the child elements are components,
* use :global
* https://stackoverflow.com/questions/56988717/how-to-target-a-component-in-svelte-with-css
*/
.monsterGrid > :global(*) {
	min-width: 300px;
}
</style>

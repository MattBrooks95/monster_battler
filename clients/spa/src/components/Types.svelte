<script>
import { onMount } from "svelte";

let types = [];

onMount(async () => {
	const response = await fetch('api/types', {
		method: 'GET'
	});
	console.log(response);

	const respJson = await response.json();
	console.log(respJson);
	types = respJson;
});
</script>

{#each types as type}
<div>type:{type.typeName} strongAgainst:{type.typeStrongAttacks.join(' ')} resists:{type.typeResists.join(' ')}</div>
{/each}

<style>
</style>

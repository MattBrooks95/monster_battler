<script>
import { onMount } from 'svelte';

let people = [];

onMount(async () => {
	const response = await fetch('api/person', {
		method: 'GET'
	});
	console.log(response);

	const respJson = await response.json();
	console.log(respJson);
	people = respJson;

});

</script>

<div>User Accounts</div>
{#each people as person}
<div>Name:{person.personName}</div>
{/each}

<style>
</style>

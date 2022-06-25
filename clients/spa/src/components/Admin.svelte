<script>
import { onMount } from 'svelte';

onMount(async () => {
	const response = await fetch('api/person', {
		method: 'GET'
	});
	console.log(response);
	const respText = await response.text();
	console.log(respText, typeof respText);
	console.log(JSON.parse(respText));

	//const respJson = await response.json();
	//console.log(respJson, JSON.parse(respJson));

});

</script>

<div>User Accounts</div>

<style>
</style>

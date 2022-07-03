<script>
import { onMount } from "svelte";

let types = [];

let typeIdMap = {};

onMount(async () => {
	const response = await fetch('api/types', {
		method: 'GET'
	});
	console.log(response);

	const respJson = await response.json();
	//console.log(respJson);
	//make a map from type id to type name, for presentation
	respJson.forEach(typeIdVal => {
		const key = typeIdVal[0];
		const typeName = typeIdVal[1].typeName;
		typeIdMap[key] = typeName;
	});

	//helper for looking up types
	const lookupType = (typeId) => typeIdMap[typeId];

	types = respJson.map(typeIdVal => {
		const typeInfo = typeIdVal[1];
		return {
			type: typeInfo.typeName,
			strongAttacks: typeInfo.typeStrongAttacks.map(lookupType),
			resists: typeInfo.typeResists.map(lookupType),
		}
	});
	console.log({ typeIdMap, types });
	//curious to see when this happens, isn't being called still, even if I display another component
	//which probably means that the components are just being hidden when a different tab is selected
	return () => {
		console.log('types component destroyed');
	};
});
</script>

{#each types as type}
<div>type:{type.type} strongAgainst:{type.strongAttacks.join(' ')} resists:{type.resists.join(' ')}</div>
{/each}

<style>
</style>

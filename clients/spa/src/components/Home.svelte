<script>
let gameCreated = false;
let gameCode = "";

async function createGame() {
	const response = await fetch('api/game/new', {
		method: 'GET'
	});
	console.log(response);
	const responseData = await response.json();
	console.log({responseData});
	gameCreated = true;
	gameCode = responseData.gameCode;
}
</script>

{#if !gameCreated}
<button on:click={createGame}>Create Game</button>
{:else}
<span>Game code:{gameCode !== "" ? gameCode : "..."}</span>
{/if}
<style>
</style>

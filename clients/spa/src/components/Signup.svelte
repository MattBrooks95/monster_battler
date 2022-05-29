<script>
let name = '';
let email = '';
function submit() {
	console.error(`TODO submit name:${name}, email:${email}`);
}
</script>

<div>
<label>Name:<input type="text" bind:value={name}/></label>
<label>Email:<input type="text" bind:value={email}/></label>
<button on:click={submit}>Submit</button>

</div>

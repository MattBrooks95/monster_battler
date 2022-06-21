<script>
let name = '';
let email = '';
function submit() {
	console.error(`TODO submit name:${name}, email:${email}`);
	fetch('api/person', {
		method: 'PUT',
		headers: {
			'Content-Type': 'application/json',
		},
		//worry about email and whatnot later
		//on the server, only grabbing the name for now
		body: JSON.stringify({
			personName: name,
		}),
	})
	.then(response => {
		console.log(response);
		return response.text();
	})
	.then(responseText => console.log(responseText))
	.catch((error) => {
		console.log('error', error)
	});
}
</script>

<div>
<label>Name:<input type="text" bind:value={name}/></label>
<label>Email:<input type="text" bind:value={email}/></label>
<button on:click={submit}>Submit</button>

</div>

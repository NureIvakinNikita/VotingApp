const Voting = artifacts.require("Voting");

contract("Voting", (accounts) => {
  let voting;

  const [owner, voter1, voter2] = accounts;

  beforeEach(async () => {
    voting = await Voting.new();
  });

  it("повинен успішно зареєструвати виборця", async () => {
    await voting.vote(1, { from: voter1 });
    const voter = await voting.voters(0);
    assert.equal(voter.voterAddress, voter1, "Виборець повинен бути зареєстрований з правильною адресою");
    assert.isTrue(voter.registered, "Виборець повинен бути зареєстрований");
    assert.isTrue(voter.voted, "Виборець повинен був проголосувати"); // Виправлено перевірку: виборець проголосував
  });

  it("не повинен дозволити виборцю зареєструватися двічі", async () => {
    await voting.vote(1, { from: voter1 });

    try {
      await voting.vote(1, { from: voter1 });
      assert.fail("Виборець не повинен мати можливості голосувати двічі");
    } catch (err) {
      assert.include(err.message, "Already voted", "Повідомлення про помилку повинно бути правильним");
    }
  });

  it("не повинен дозволяти виборцю голосувати двічі", async () => {
    await voting.vote(1, { from: voter1 });

    try {
      await voting.vote(1, { from: voter1 });
      assert.fail("Виборець не повинен мати можливості голосувати двічі");
    } catch (err) {
      assert.include(err.message, "Already voted", "Повідомлення про помилку повинно бути правильним");
    }
  });

  it("не повинен дозволяти голосування за недійсного кандидата", async () => {
    await voting.vote(1, { from: voter1 });

    try {
      await voting.vote(3, { from: voter1 }); // Недійсний ID кандидата
      assert.fail("Виборець не повинен мати можливості голосувати за недійсного кандидата");
    } catch (err) {
      assert.include(err.message, "Invalid candidate", "Повідомлення про помилку повинно бути правильним");
    }
  });

  it("повинен дозволяти власнику додавати кандидатів", async () => {
    await voting.addCandidate("Кандидат 3", "https://example.com/photo3.jpg", { from: owner });

    const candidate = await voting.getCandidate(3);
    assert.equal(candidate[0], "Кандидат 3", "Ім'я кандидата повинно бути правильним");
    assert.equal(candidate[2], "https://example.com/photo3.jpg", "URL фото кандидата повинен бути правильним");
  });

  it("не повинен дозволяти не-власникам додавати кандидатів", async () => {
    try {
      await voting.addCandidate("Кандидат 4", "https://example.com/photo4.jpg", { from: voter1 });
      assert.fail("Лише власник повинен мати можливість додавати кандидатів");
    } catch (err) {
      assert.include(err.message, "Only owner can call this", "Повідомлення про помилку повинно бути правильним");
    }
  });
});

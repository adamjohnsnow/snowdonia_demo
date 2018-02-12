
describe User do

  context 'user creation' do

    it 'create user' do
      User.create("Firstname", "Surname", "email@email.com", "password", "role", 2)
      expect(User.all.count).to eq 1
    end

    it 'no duplicate user' do
      User.create("Firstname", "Surname", "email@email.com", "password", "role", 2)
      expect(User.all.count).to eq 1
    end

    it 'add second user' do
      User.create("Firstname", "Surname", "email2@email.com", "password", "role", 3)
      expect(User.all.count).to eq 2
    end

    it { expect(User.first.firstname).to eq "Firstname" }

    it { expect(User.first.surname).to eq "Surname" }

    it { expect(User.first.email).to eq "email@email.com" }

    it { expect(User.first.level).to eq 2 }

  end

  context 'user log in' do

    it 'can log in' do
      user = User.login({ email: 'email@email.com', password: 'password' })
      expect(user.firstname).to eq 'Firstname'
    end

    it 'log in fail' do
      user = User.login({ email: 'email@email.com', password: 'wrong' })
      expect(user).to eq nil
    end
  end
end
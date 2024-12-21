require_relative '../../../libraries/default'

describe 'Boxcutter::CouchDB::Helpers' do
  it 'should correctly compare a password hasnt changed against hash' do
    password = 'superseekret'
    password_hash = Boxcutter::CouchDB::Helpers.generate_pbkdf2_password_hash(password)
    password_changed = Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(password, password_hash)
    expect(password_changed).to be false
  end

  it 'should detect that a password changed when its hash doesnt match' do
    password_one = 'superseekret'
    password_one_hash = Boxcutter::CouchDB::Helpers.generate_pbkdf2_password_hash(password_one)
    expect(Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(password_one, password_one_hash)).to be false

    password_two = 'supersuperseekret'
    password_two_hash = Boxcutter::CouchDB::Helpers.generate_pbkdf2_password_hash(password_two)
    expect(Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(password_two, password_two_hash)).to be false

    expect(Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(password_one, password_two_hash)).to be true
    expect(Boxcutter::CouchDB::Helpers.verify_pbkdf2_hash(password_two, password_one_hash)).to be true
  end
end

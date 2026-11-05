package examples.users;

import com.intuit.karate.junit5.Karate;

class UsersRunner {

    @Karate.Test
    Karate testUsers() {
        return Karate.run(
                        "classpath:examples/users/regression-users.feature",
                        "classpath:examples/users/admin-flow.feature"
                )
                .tags("@regression")
                .reportDir("target/karate-reports")
                .outputCucumberJson(true);
    }
}

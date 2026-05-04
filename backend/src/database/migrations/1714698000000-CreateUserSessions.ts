import { MigrationInterface, QueryRunner } from "typeorm";

export class CreateUserSessions1714698000000 implements MigrationInterface {
  name = "CreateUserSessions1714698000000";

  async up(queryRunner: QueryRunner): Promise<void> {
    const hasTable = await queryRunner.hasTable("user_sessions");
    if (hasTable) return;

    await queryRunner.query(`
      CREATE TABLE \`user_sessions\` (
        \`id\` varchar(36) NOT NULL,
        \`user_id\` int NOT NULL,
        \`refresh_token_hash\` varchar(255) NOT NULL,
        \`expires_at\` datetime NOT NULL,
        \`revoked_at\` datetime NULL,
        \`last_used_at\` datetime NULL,
        \`user_agent\` varchar(500) NULL,
        \`ip_address\` varchar(80) NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        INDEX \`IDX_user_sessions_user_id\` (\`user_id\`),
        PRIMARY KEY (\`id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      ALTER TABLE \`user_sessions\`
      ADD CONSTRAINT \`FK_user_sessions_user_id\`
      FOREIGN KEY (\`user_id\`) REFERENCES \`users\`(\`id\`)
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    const hasTable = await queryRunner.hasTable("user_sessions");
    if (!hasTable) return;

    await queryRunner.query(`
      ALTER TABLE \`user_sessions\`
      DROP FOREIGN KEY \`FK_user_sessions_user_id\`
    `);
    await queryRunner.query("DROP TABLE IF EXISTS `user_sessions`");
  }
}

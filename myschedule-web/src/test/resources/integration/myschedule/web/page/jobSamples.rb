# Simple Jobs
# ===========
require 'java'
java_import Java::MyscheduleQuartzExtraJob::LoggerJob
java_import Java::MyscheduleQuartzExtraJob::ScriptingJob
java_import Java::MyscheduleQuartzExtra::SchedulerTemplate
java_import Java::JavaUtil::Date
java_import Java::JavaLang::System

# Schedule hourly job
scheduler.schedule_simple_job("hourlyJob", -1, 60 * 60 * 1000, LoggerJob.java_class)

# Schedule minutely job
scheduler.schedule_simple_job("minutelyJob", -1, 60 * 1000, LoggerJob.java_class)

# Schedule secondly job
scheduler.schedule_simple_job("secondlyJob", -1, 1000, LoggerJob.java_class)

# Schedule secondly job that repeat total of 3 times.
scheduler.schedule_simple_job("secondlyJobRepeat3", 3, 1000, LoggerJob.java_class)

# Schedule onetime job that run immediately
scheduler.schedule_simple_job("onetimeJob", 1, 0, LoggerJob.java_class)

# Schedule hourly job with job data and start time of 20s delay.
scheduler.schedule_simple_job("hourlyJobWithStartTimeDelay", -1, 60 * 60 * 1000, ScriptingJob.java_class,
                SchedulerTemplate.mk_map(
                        'ScriptEngineName', 'Groovy',
                        'ScriptText', '''
                                logger.info("I am a script job...")
                                sleep(700L)
                                logger.info("I am done.")
                        '''
                ),
                Date.new(System.current_time_millis() + 20 * 1000))

# Schedule one job with multiple triggers
require 'java'
java_import Java::OrgQuartz::JobKey
java_import Java::MyscheduleQuartzExtraJob::LoggerJob
java_import Java::MyscheduleQuartzExtra::SchedulerTemplate

job = SchedulerTemplate.create_job_detail(JobKey.job_key("jobWithMutltipleTriggers"), LoggerJob.java_class, true, nil)
scheduler.add_job(job, false)
trigger1 = SchedulerTemplate.create_simple_trigger("trigger1", -1, 60 * 60 * 1000) # hourly trigger
trigger1.set_job_key(job.get_key())
scheduler.schedule_job(trigger1)
trigger2 = SchedulerTemplate.create_simple_trigger("trigger2", -1, 60 * 1000) # minutely trigger
trigger2.set_job_key(job.get_key())
scheduler.schedule_job(trigger2)

# Using Java org.scheduler.Scheduler API
# ===================================================
require 'java'
java_import Java::OrgQuartz::JobBuilder
java_import Java::OrgQuartz::TriggerBuilder
java_import Java::OrgQuartz::SimpleScheduleBuilder
java_import Java::MyscheduleQuartzExtraJob::LoggerJob

quartzScheduler = scheduler.getScheduler()
job = JobBuilder.
        newJob(LoggerJob.java_class).
        withIdentity("hourlyJob2").
        build()
trigger = TriggerBuilder.
        newTrigger().
        withSchedule(
                SimpleScheduleBuilder.repeatHourlyForever()).
        build()
quartzScheduler.scheduleJob(job, trigger)


# Calendar Jobs
# =============
# Create Quartz Calendar objects
require 'java'
java_import Java::OrgQuartzImplCalendar::CronCalendar
java_import Java::MyscheduleQuartzExtraJob::LoggerJob
java_import Java::MyscheduleQuartzExtra::SchedulerTemplate

cal = CronCalendar.new('* * * * JAN ?')
scheduler.add_calendar('SkipJan', cal, true, false)
cal = CronCalendar.new('* * * ? * SAT,SUN')
scheduler.add_calendar('SkipWeekEnd', cal, true, false)
cal = CronCalendar.new('* * 12-13 * * ?')
scheduler.add_calendar('SkipLunch', cal, true, false)

# Create jobs that uses the calendars.
job = SchedulerTemplate.create_job_detail('CalJob', LoggerJob.java_class)
trigger = SchedulerTemplate.create_cron_trigger('CalJob1', '0 0 * * * ?')
trigger.set_calendar_name('SkipWeekEnd')
scheduler.schedule_job(job, trigger)

job = SchedulerTemplate.create_job_detail('CalJob2', LoggerJob.java_class)
trigger = SchedulerTemplate.create_cron_trigger('CalJob2', '0 0 * * * ?')
trigger.set_calendar_name('SkipJan')
scheduler.schedule_job(job, trigger)

job = SchedulerTemplate.create_job_detail('CalJob3', LoggerJob.java_class)
trigger = SchedulerTemplate.create_cron_trigger('CalJob3', '0 0 * * * ?')
trigger.set_calendar_name('SkipLunch')
scheduler.schedule_job(job, trigger)

# Cron Jobs
# =========
# For more on CRON expression format, see http:#www.quartz-scheduler.org/api/2.1.0/org/quartz/CronExpression.html
require 'java'
java_import Java::MyscheduleQuartzExtraJob::LoggerJob
java_import Java::MyscheduleQuartzExtra::SchedulerTemplate
java_import Java::JavaUtil::Date
java_import Java::JavaLang::System

# Schedule hourly job on every MON-FRI
scheduler.schedule_cron_job("hourlyCronJob", "0 0 * ? * MON-FRI", LoggerJob.java_class)

# Schedule minutely job on JUN and DEC only
scheduler.schedule_cron_job("minutelyCronJob", "0 * * * JUN,DEC ?", LoggerJob.java_class)

# Schedule secondly job
scheduler.schedule_cron_job("secondlyCronJob", "* * * * * ?", LoggerJob.java_class)

# Schedule hourly job with job data and start time of 20s delay.
scheduler.schedule_cron_job("hourlyCronJobWithStartTimeDelay", "0 0 * * * ?", LoggerJob.java_class,
                SchedulerTemplate.mk_map('color', 'RED'),
                Date.new(System.current_time_millis() + 20 * 1000))

# Schedule one job with multiple triggers
require 'java'
java_import Java::OrgQuartz::JobKey
java_import Java::MyscheduleQuartzExtraJob::LoggerJob
java_import Java::MyscheduleQuartzExtra::SchedulerTemplate

job = SchedulerTemplate.create_job_detail(JobKey.job_key("jobWithMutltipleTriggers2"), LoggerJob.java_class, true, nil)
scheduler.add_job(job, false)
trigger1 = scheduler.schedule_cron_job("cronTrigger1", "0 0 * * * ?") # hourly trigger
trigger1.set_job_key(job.get_key())
scheduler.schedule_job(trigger1)
trigger2 = scheduler.schedule_cron_job("cronTrigger2", "0 * * * * ?") # minutely trigger
trigger2.set_job_key(job.get_key())
scheduler.schedule_job(trigger2)

# Using Java org.scheduler.Scheduler API
# ===================================================
require 'java'
java_import Java::OrgQuartz::JobBuilder
java_import Java::OrgQuartz::TriggerBuilder
java_import Java::OrgQuartz::CronScheduleBuilder
java_import Java::MyscheduleQuartzExtraJob::LoggerJob

quartzScheduler = scheduler.getScheduler()
job = JobBuilder.
        newJob(LoggerJob.java_class).
        withIdentity("hourlyCronJob2").
        build()
trigger = TriggerBuilder.
        newTrigger().
        withSchedule(
                CronScheduleBuilder.cronSchedule("0 0 * * * ?")).
        build()
quartzScheduler.scheduleJob(job, trigger)